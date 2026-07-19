// DayViewModel.swift
import Foundation

@Observable
@MainActor
final class DayViewModel {
    private let taskRepository: TaskRepositoryProtocol
    let notificationService: NotificationService

    var tasksToday: [PareTask] = []
    var selectedDate: Date = Date()
    var streak: Int = 0
    var overdueFromYesterday: [PareTask] = []
    var suggestions: [PareTask] = []

    // IDs de tareas completándose — para animación de salida
    var completingTaskIDs: Set<UUID> = []

    // Ajuste de planificación (ver SettingsView). Se lee directamente de
    // UserDefaults en vez de usar @AppStorage porque este tipo no es una
    // View: no necesitamos invalidación automática, solo el valor actual
    // cada vez que se recarga el día.
    private var autoHideCompletedTasks: Bool {
        UserDefaults.standard.object(forKey: "autoHideCompletedTasks") as? Bool ?? true
    }

    init(
        taskRepository: TaskRepositoryProtocol,
        notificationService: NotificationService
    ) {
        self.taskRepository = taskRepository
        self.notificationService = notificationService
    }

    func loadDay(for date: Date) {
        selectedDate = Calendar.current.startOfDay(for: date)

        let fetched = taskRepository.tasks(for: selectedDate)
        let visibleTasks = autoHideCompletedTasks ? fetched.filter { !$0.isCompleted } : fetched
        tasksToday = sortTasks(visibleTasks)

        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            overdueFromYesterday = sortTasks(
                taskRepository.tasks(for: yesterday).filter { !$0.isCompleted }
            )
        } else {
            overdueFromYesterday = []
        }

        let pending = taskRepository.allPending()
        suggestions = SmartScheduler.suggestions(from: pending, for: selectedDate)
        streak = calculateStreak()
    }

    // MARK: - Complete con animación de salida

    func complete(_ task: PareTask) {
        // 1. Marcar como "completándose" para animación
        completingTaskIDs.insert(task.id)

        // 2. Esperar la animación de salida (0.35s) y luego persistir + recargar
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            self.completingTaskIDs.remove(task.id)
            self.notificationService.cancel(for: task)
            try? self.taskRepository.complete(task)
            self.loadDay(for: self.selectedDate)
        }
    }

    func reschedule(_ task: PareTask, to date: Date) {
        notificationService.cancel(for: task)
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        task.scheduledDate = dayStart

        if let time = task.scheduledTime {
            let parts = calendar.dateComponents([.hour, .minute], from: time)
            task.scheduledTime = calendar.date(
                bySettingHour: parts.hour ?? 0,
                minute: parts.minute ?? 0,
                second: 0,
                of: dayStart
            )
        }

        try? taskRepository.save(task)
        notificationService.schedule(for: task)
        loadDay(for: selectedDate)
    }

    func addTask(_ task: PareTask) {
        try? taskRepository.save(task)
        notificationService.schedule(for: task)
        loadDay(for: selectedDate)
    }

    func deleteTask(_ task: PareTask) {
        notificationService.cancel(for: task)
        try? taskRepository.delete(task)
        loadDay(for: selectedDate)
    }

    // MARK: - Private

    private func sortTasks(_ tasks: [PareTask]) -> [PareTask] {
        tasks.sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority.rawValue > rhs.priority.rawValue
            }
            switch (lhs.scheduledTime, rhs.scheduledTime) {
            case let (l?, r?): return l < r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
        }
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var count = 0
        var date = calendar.startOfDay(for: Date())

        if streakStatus(for: date) == .failed,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }

        for _ in 0..<365 {
            switch streakStatus(for: date) {
            case .passed:  count += 1
            case .skipped: break
            case .failed:  return count
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else {
                return count
            }
            date = previous
        }
        return count
    }

    private enum StreakStatus { case passed, skipped, failed }

    private func streakStatus(for date: Date) -> StreakStatus {
        let focus = taskRepository.tasks(for: date)
            .filter { $0.priority == .must || $0.priority == .high }
        if focus.isEmpty { return .skipped }
        return focus.allSatisfy(\.isCompleted) ? .passed : .failed
    }
}
