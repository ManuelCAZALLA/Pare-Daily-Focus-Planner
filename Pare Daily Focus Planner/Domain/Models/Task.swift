// Task.swift — SwiftData Model
import Foundation
import SwiftData

@Model
final class PareTask {
    var id: UUID
    var title: String
    var notes: String?
    var scheduledDate: Date
    var scheduledTime: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var priority: Priority
    var recurrenceRaw: String? // Codable Recurrence serializada
    var notificationIDs: [String]
    var alertOffsetRaw: Double?
    var createdAt: Date
    var weekPlan: WeekPlan?

    var alertOffset: TaskAlertOffset? {
        get {
            guard let raw = alertOffsetRaw else { return nil }
            return TaskAlertOffset(rawValue: raw)
        }
        set {
            alertOffsetRaw = newValue?.rawValue
        }
    }

    init(
        title: String,
        scheduledDate: Date,
        priority: Priority = .medium
    ) {
        self.id = UUID()
        self.title = title
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.priority = priority
        self.notificationIDs = []
        self.alertOffsetRaw = nil
        self.createdAt = Date()
    }
}

enum TaskAlertOffset: Double, CaseIterable, Identifiable, Codable {
    case atTime = 0
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case twentyMinutes = 1200
    case thirtyMinutes = 1800
    case oneHour = 3600
    case twoHours = 7200
    case oneDay = 86400

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .atTime: return String(localized: "A la hora del evento")
        case .fiveMinutes: return String(localized: "5 minutos antes")
        case .tenMinutes: return String(localized: "10 minutos antes")
        case .fifteenMinutes: return String(localized: "15 minutos antes")
        case .twentyMinutes: return String(localized: "20 minutos antes")
        case .thirtyMinutes: return String(localized: "30 minutos antes")
        case .oneHour: return String(localized: "1 hora antes")
        case .twoHours: return String(localized: "2 horas antes")
        case .oneDay: return String(localized: "1 día antes")
        }
    }
}
