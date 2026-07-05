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
            return String(localized: "Cada día")
        case .weekly(let days) where days.count == 5:
            return String(localized: "Días laborables (Lun–Vie)")
        case .weekly(let days) where days.count == 7:
            return String(localized: "Todos los días de la semana")
        case .weekly(let days):
            return String(localized: "Semanalmente (\(days.count) días)")
        case .monthly(let day):
            return String(localized: "Mensual el día \(day)")
        case .custom(let n) where n == 2:
            return String(localized: "Cada 2 días")
        case .custom(let n) where n == 7:
            return String(localized: "Cada semana")
        case .custom(let n):
            return String(localized: "Cada \(n) días")
        }
    }
}
