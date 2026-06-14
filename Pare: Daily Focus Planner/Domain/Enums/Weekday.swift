// Weekday.swift
import Foundation

enum Weekday: Int, CaseIterable, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var short: String {
        ["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"][rawValue - 1]
    }

    var full: String {
        ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"][rawValue - 1]
    }
}
