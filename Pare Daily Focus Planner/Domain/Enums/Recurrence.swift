// Recurrence.swift
import Foundation

enum Recurrence: Codable, Equatable, Hashable {
    case daily
    case weekly(days: [Int])   // 1=Lunes … 7=Domingo
    case monthly(day: Int)
    case custom(intervalDays: Int)

    var label: String {
        switch self {
        case .daily:
            return "Every day"
        case .weekly(let days) where days.count == 5:
            return "Weekdays (Mon–Fri)"
        case .weekly(let days) where days.count == 7:
            return "Every day of the week"
        case .weekly(let days):
            return "Weekly (\(days.count) days)"
        case .monthly(let day):
            return "Monthly on day \(day)"
        case .custom(let n) where n == 2:
            return "Every 2 days"
        case .custom(let n) where n == 7:
            return "Every week"
        case .custom(let n):
            return "Every \(n) days"
        }
    }
}
