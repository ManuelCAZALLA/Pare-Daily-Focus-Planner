// TramiteWidgetDataLoader.swift
// Lee los datos del almacén SwiftData compartido (App Group).
import Foundation
import SwiftData

enum TramiteWidgetStore {
    static let id = "group.com.manuelcazalla.recuerdatustramites"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
    }

    static var storeURL: URL? {
        guard let containerURL = containerURL else { return nil }
        let newURL = containerURL.appendingPathComponent("recuerdatustramites.sqlite")
        if FileManager.default.fileExists(atPath: newURL.path) {
            return newURL
        }
        let daySortedURL = containerURL.appendingPathComponent("daysorted.sqlite")
        if FileManager.default.fileExists(atPath: daySortedURL.path) {
            return daySortedURL
        }
        let pareURL = containerURL.appendingPathComponent("pare.sqlite")
        if FileManager.default.fileExists(atPath: pareURL.path) {
            return pareURL
        }
        return newURL
    }
}

struct TramiteWidgetDataLoader {

    @MainActor
    func load() -> TramiteWidgetEntry? {
        guard let storeURL = TramiteWidgetStore.storeURL else { return nil }

        let schema = Schema([
            TramiteTask.self, WeekPlan.self, LifeObligation.self,
            DailyRitual.self, FamilyProfile.self
        ])
        let config = ModelConfiguration(schema: schema, url: storeURL)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return nil
        }
        let context = container.mainContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        // MARK: - Tareas de hoy
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(86_400)
        let taskPredicate = #Predicate<TramiteTask> { $0.scheduledDate >= today && $0.scheduledDate < tomorrow }
        let tasksToday = (try? context.fetch(FetchDescriptor(predicate: taskPredicate))) ?? []

        let widgetTasks = tasksToday.map { task in
            WidgetTask(
                id: task.id,
                title: task.title,
                isCompleted: task.isCompleted,
                priority: task.priority.rawValue,
                scheduledTime: task.scheduledTime
            )
        }

        // MARK: - Trámites ordenados por vencimiento
        let allObligations = (try? context.fetch(FetchDescriptor<LifeObligation>())) ?? []
        let dated = allObligations.compactMap { obligation -> (LifeObligation, Int)? in
            guard let expiry = obligation.expiryDate else { return nil }
            let end = calendar.startOfDay(for: expiry)
            let days = calendar.dateComponents([.day], from: today, to: end).day ?? 0
            return (obligation, days)
        }
        .sorted { $0.1 < $1.1 }

        let widgetObligations = dated.prefix(2).map { obligation, days in
            let template = ObligationTemplate.all.first { $0.id == obligation.templateID }
            return WidgetObligation(
                id: obligation.id,
                title: template?.title ?? obligation.templateID,
                daysRemaining: days,
                categoryIcon: template?.category.systemImage ?? "doc.text.fill",
                categoryName: template?.category.title ?? ""
            )
        }

        // MARK: - Rutina
        let rituals = (try? context.fetch(FetchDescriptor<DailyRitual>())) ?? []
        let morningDone = hasRitual(rituals, date: today, type: .morning, calendar: calendar)
        let eveningDone = hasRitual(rituals, date: today, type: .evening, calendar: calendar)
        let streak = calculateStreak(rituals: rituals, calendar: calendar)

        return TramiteWidgetEntry(
            date: .now,
            tasks: widgetTasks,
            urgentObligation: widgetObligations.first,
            obligations: Array(widgetObligations),
            morningDone: morningDone,
            eveningDone: eveningDone,
            streak: streak
        )
    }

    // MARK: - Rutina

    private func hasRitual(
        _ rituals: [DailyRitual],
        date: Date,
        type: RitualType,
        calendar: Calendar
    ) -> Bool {
        let end = calendar.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86_400)
        return rituals.contains { $0.date >= date && $0.date < end && $0.typeRaw == type.rawValue }
    }

    /// Misma lógica que RoutineViewModel: cuenta los días consecutivos en los
    /// que se completaron mañana y noche, empezando hoy (o ayer si hoy no cierra).
    private func calculateStreak(rituals: [DailyRitual], calendar: Calendar) -> Int {
        var streak = 0
        var date = calendar.startOfDay(for: .now)

        let todayDone = hasRitual(rituals, date: date, type: .morning, calendar: calendar)
            && hasRitual(rituals, date: date, type: .evening, calendar: calendar)
        if !todayDone {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }

        for _ in 0..<365 {
            let morning = hasRitual(rituals, date: date, type: .morning, calendar: calendar)
            let evening = hasRitual(rituals, date: date, type: .evening, calendar: calendar)
            if morning && evening {
                streak += 1
            } else {
                break
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }
}