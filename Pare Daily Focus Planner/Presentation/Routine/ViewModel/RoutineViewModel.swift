//
//  RoutineViewModel.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 18/07/2026.
//

import Foundation
import SwiftUI
import SwiftData
import UserNotifications

// MARK: - RoutineViewModel

@Observable
@MainActor
final class RoutineViewModel {

    // MARK: - Estado diario
    var todayMorningCompleted: Bool = false
    var todayEveningCompleted: Bool = false
    var streakDays: Int = 0

    // MARK: - Configuración (observables, persistidas en UserDefaults)
    var morningEnabled: Bool = UserDefaults.standard.object(forKey: "routine.morningEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(morningEnabled, forKey: "routine.morningEnabled"); scheduleNotifications() }
    }
    var eveningEnabled: Bool = UserDefaults.standard.object(forKey: "routine.eveningEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(eveningEnabled, forKey: "routine.eveningEnabled"); scheduleNotifications() }
    }
    var morningHour: Int = UserDefaults.standard.object(forKey: "routine.morningHour") as? Int ?? 8 {
        didSet { UserDefaults.standard.set(morningHour, forKey: "routine.morningHour"); scheduleNotifications() }
    }
    var morningMinute: Int = UserDefaults.standard.object(forKey: "routine.morningMinute") as? Int ?? 0 {
        didSet { UserDefaults.standard.set(morningMinute, forKey: "routine.morningMinute"); scheduleNotifications() }
    }
    var eveningHour: Int = UserDefaults.standard.object(forKey: "routine.eveningHour") as? Int ?? 21 {
        didSet { UserDefaults.standard.set(eveningHour, forKey: "routine.eveningHour"); scheduleNotifications() }
    }
    var eveningMinute: Int = UserDefaults.standard.object(forKey: "routine.eveningMinute") as? Int ?? 0 {
        didSet { UserDefaults.standard.set(eveningMinute, forKey: "routine.eveningMinute"); scheduleNotifications() }
    }

    // MARK: - Computed dates para UI
    var morningTime: Date {
        get {
            Calendar.current.date(
                bySettingHour: morningHour,
                minute: morningMinute,
                second: 0,
                of: Date()
            ) ?? Date()
        }
        set {
            let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            morningHour = c.hour ?? 8
            morningMinute = c.minute ?? 0
        }
    }
    var eveningTime: Date {
        get {
            Calendar.current.date(
                bySettingHour: eveningHour,
                minute: eveningMinute,
                second: 0,
                of: Date()
            ) ?? Date()
        }
        set {
            let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            eveningHour = c.hour ?? 21
            eveningMinute = c.minute ?? 0
        }
    }


    // MARK: - Sheet control
    var showMorningFlow: Bool = false
    var showEveningFlow: Bool = false

    // MARK: - Dependencias
    private let context: ModelContext
    private let taskRepository: TaskRepositoryProtocol

    // MARK: - Init
    init(context: ModelContext, taskRepository: TaskRepositoryProtocol) {
        self.context = context
        self.taskRepository = taskRepository
        loadStreakAndStatus()
    }

    // MARK: - Carga de estado

    func loadStreakAndStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        todayMorningCompleted = hasRitual(for: today, type: .morning)
        todayEveningCompleted = hasRitual(for: today, type: .evening)
        streakDays = calculateStreak()
    }

    // MARK: - Completar Morning

    func completeMorning(intentionTaskID: UUID?) {
        let ritual = DailyRitual(date: Date(), type: .morning)
        ritual.intentionTaskID = intentionTaskID
        context.insert(ritual)
        try? context.save()
        withAnimation { todayMorningCompleted = true }
        streakDays = calculateStreak()
    }

    // MARK: - Completar Evening

    func completeEvening(note: String?, carriedOverTasks: [PareTask]) {
        let ritual = DailyRitual(date: Date(), type: .evening)
        ritual.eveningNote = note.flatMap { $0.isEmpty ? nil : $0 }
        ritual.carriedOverTaskIDs = carriedOverTasks.map(\.id)
        context.insert(ritual)
        try? context.save()

        // Posponer tareas seleccionadas a mañana
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        for task in carriedOverTasks {
            task.scheduledDate = tomorrow
            try? taskRepository.save(task)
        }

        withAnimation { todayEveningCompleted = true }
        streakDays = calculateStreak()
    }

    // MARK: - Notificaciones

    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "routine.morning", "routine.evening"
        ])

        if morningEnabled {
            scheduleDaily(
                id: "routine.morning",
                hour: morningHour,
                minute: morningMinute,
                title: "Buenos días 🌅",
                body: "Es momento de preparar tu día con Pare."
            )
        }
        if eveningEnabled {
            scheduleDaily(
                id: "routine.evening",
                hour: eveningHour,
                minute: eveningMinute,
                title: "Cierre del día 🌙",
                body: "Revisa cómo fue tu día y prepara el de mañana."
            )
        }
    }

    // MARK: - Urgente trámites para briefing

    func urgentObligations() -> [LifeObligation] {
        let descriptor = FetchDescriptor<LifeObligation>()
        let all = (try? context.fetch(descriptor)) ?? []
        return all.filter { ($0.daysUntilExpiry ?? Int.max) <= 7 }
            .sorted { ($0.daysUntilExpiry ?? 999) < ($1.daysUntilExpiry ?? 999) }
    }

    // MARK: - Tareas de hoy para evening

    func tasksForToday() -> [PareTask] {
        taskRepository.tasks(for: Calendar.current.startOfDay(for: Date()))
    }

    // MARK: - Private

    private func hasRitual(for date: Date, type: RitualType) -> Bool {
        let start = date
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let typeRaw = type.rawValue
        let descriptor = FetchDescriptor<DailyRitual>(
            predicate: #Predicate { $0.date >= start && $0.date < end && $0.typeRaw == typeRaw }
        )
        return ((try? context.fetch(descriptor))?.isEmpty == false)
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        // Si hoy no está completo, comprobamos desde ayer
        let todayDone = hasRitual(for: date, type: .morning) && hasRitual(for: date, type: .evening)
        if !todayDone {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }

        for _ in 0..<365 {
            let morning = hasRitual(for: date, type: .morning)
            let evening = hasRitual(for: date, type: .evening)
            if morning && evening {
                streak += 1
            } else {
                break
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    private func scheduleDaily(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
