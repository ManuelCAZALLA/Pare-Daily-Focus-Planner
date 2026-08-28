// Priority.swift
import Foundation

enum Priority: Int, Codable, CaseIterable {
    case low    = 0
    case medium = 1
    case high   = 2
    case must   = 3  // "sí o sí hoy"

    var label: String {
        switch self {
        case .low:    return String(localized: "Baja")
        case .medium: return String(localized: "Media")
        case .high:   return String(localized: "Alta")
        case .must:   return String(localized: "Imprescindible")
        }
    }
}
