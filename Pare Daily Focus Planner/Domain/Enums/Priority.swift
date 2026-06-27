// Priority.swift
import Foundation

enum Priority: Int, Codable, CaseIterable {
    case low    = 0
    case medium = 1
    case high   = 2
    case must   = 3  // "sí o sí hoy"

    var label: String {
        switch self {
        case .low:    return "Baja"
        case .medium: return "Media"
        case .high:   return "Alta"
        case .must:   return "Imprescindible"
        }
    }
}
