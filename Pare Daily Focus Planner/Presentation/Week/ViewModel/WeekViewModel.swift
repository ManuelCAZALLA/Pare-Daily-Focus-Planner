// WeekViewModel.swift

import Foundation
import SwiftData

@Observable
@MainActor
final class WeekViewModel {
    private let weekPlanRepository: WeekPlanRepositoryProtocol
    private let taskRepository: TaskRepositoryProtocol

    var currentPlan: WeekPlan?
    var tasksByDay: [Date: [PareTask]] = [:]
    var weekDates: [Date] = []
    var selectedDate: Date = Date()
    var showReview: Bool = false

    // Stats de la semana
    var weekCompletionRate: Double = 0
    var totalTasksThisWeek: Int = 0
    var completedTasksThisWeek: Int = 0

    init(
        weekPlanRepository: WeekPlanRepositoryProtocol,
        taskRepository: TaskRepositoryProtocol
    ) {
        self.weekPlanRepository = weekPlanRepository
        self.taskRepository = taskRepository
    }

    // MARK: - Load

    func loadWeek(containing date: Date = Date()) {
        selectedDate = date
        weekDates = currentWeekDays(for: date)
        currentPlan = weekPlanRepository.weekPlan(for: date)

        tasksByDay = [:]
        for day in weekDates {
            let tasks = taskRepository.tasks(for: day)
            tasksByDay[day] = sortTasks(tasks)
        }

        calculateWeekStats()
    }

    func loadNextWeek() {
        guard let next = Calendar.current.date(
            byAdding: .weekOfYear, value: 1, to: selectedDate
        ) else { return }
        loadWeek(containing: next)
    }

    func loadPreviousWeek() {
        guard let prev = Calendar.current.date(
            byAdding: .weekOfYear, value: -1, to: selectedDate
        ) else { return }
        loadWeek(containing: prev)
    }

    // MARK: - Tasks

    func tasks(for day: Date) -> [PareTask] {
        let key = Calendar.current.startOfDay(for: day)
        return tasksByDay[key] ?? []
    }

    func moveTask(_ task: PareTask, to date: Date) {
        let calendar = Calendar.current
        let dayStart  = calendar.startOfDay(for: date)
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
        loadWeek(containing: selectedDate)
    }

    func complete(_ task: PareTask) {
        try? taskRepository.complete(task)
        loadWeek(containing: selectedDate)
    }

    // MARK: - Week plan

    func createWeekPlanIfNeeded() {
        guard currentPlan == nil else { return }
        let monday = weekDates.first ?? Date()
        currentPlan = try? weekPlanRepository.createWeekPlan(starting: monday)
    }

    // MARK: - Computed helpers

    var isCurrentWeek: Bool {
        Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var weekRangeLabel: String {
        guard let first = weekDates.first, let last = weekDates.last else { return "" }
        let f = first.formatted(.dateTime.day().month(.abbreviated))
        let l = last.formatted(.dateTime.day().month(.abbreviated).year())
        return "\(f) – \(l)"
    }

    func completionRate(for day: Date) -> Double {
        let t = tasks(for: day)
        guard !t.isEmpty else { return 0 }
        return Double(t.filter(\.isCompleted).count) / Double(t.count)
    }

    func pendingCount(for day: Date) -> Int {
        tasks(for: day).filter { !$0.isCompleted }.count
    }

    // MARK: - Private

    private func currentWeekDays(for date: Date) -> [Date] {
        let cal   = Calendar(identifier: .iso8601)
        let start = cal.date(from: cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: date
        )) ?? date
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func sortTasks(_ tasks: [PareTask]) -> [PareTask] {
        tasks.sorted { lhs, rhs in
            if lhs.priority.rawValue != rhs.priority.rawValue {
                return lhs.priority.rawValue > rhs.priority.rawValue
            }
            switch (lhs.scheduledTime, rhs.scheduledTime) {
            case let (l?, r?): return l < r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return lhs.title < rhs.title
            }
        }
    }

    private func calculateWeekStats() {
        let allTasks = weekDates.flatMap { tasks(for: $0) }
        totalTasksThisWeek     = allTasks.count
        completedTasksThisWeek = allTasks.filter(\.isCompleted).count
        weekCompletionRate     = totalTasksThisWeek > 0
            ? Double(completedTasksThisWeek) / Double(totalTasksThisWeek)
            : 0
    }
}
