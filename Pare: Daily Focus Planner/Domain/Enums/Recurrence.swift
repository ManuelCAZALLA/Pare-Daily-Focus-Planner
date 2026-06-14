// Recurrence.swift
import Foundation

enum Recurrence: Codable, Equatable {
    case daily
    case weekly(days: [Int])   // 1=Lunes … 7=Domingo
    case monthly(day: Int)
    case custom(intervalDays: Int)

    var label: String {
        switch self {
        case .daily:                    return "Cada día"
        case .weekly(let days):         return "Semanal (\(days.count) días)"
        case .monthly(let day):         return "Mensual (día \(day))"
        case .custom(let n):            return "Cada \(n) días"
        }
    }
}
