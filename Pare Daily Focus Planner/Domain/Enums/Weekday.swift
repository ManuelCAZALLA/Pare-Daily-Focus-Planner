// Weekday.swift
import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var short: String {
        [
            String(localized: "Lun"),
            String(localized: "Mar"),
            String(localized: "Mié"),
            String(localized: "Jue"),
            String(localized: "Vie"),
            String(localized: "Sáb"),
            String(localized: "Dom")
        ][rawValue - 1]
    }

    var full: String {
        [
            String(localized: "Lunes"),
            String(localized: "Martes"),
            String(localized: "Miércoles"),
            String(localized: "Jueves"),
            String(localized: "Viernes"),
            String(localized: "Sábado"),
            String(localized: "Domingo")
        ][rawValue - 1]
    }
}
