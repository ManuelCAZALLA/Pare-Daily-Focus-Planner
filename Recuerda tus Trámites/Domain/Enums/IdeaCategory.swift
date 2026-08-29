// IdeaCategory.swift
import Foundation

/// Categoría de un post-it en el muro de ideas. Cada categoría tiene su
/// propio color y un icono, de modo que el muro se lee de un vistazo sin
/// necesidad de listas jerárquicas.
enum IdeaCategory: String, CaseIterable, Identifiable, Codable {
    case idea       // "lightbulb"      — ideas en general
    case tramite    // "doc.text"       — trámites / gestiones
    case familia    // "person.2"       — personas y familia
    case casa       // "house"          — hogar y compras
    case otro       // "ellipsis"       — resto

    var id: String { rawValue }

    var label: String {
        switch self {
        case .idea:    return String(localized: "ideas.category.idea")
        case .tramite: return String(localized: "ideas.category.tramite")
        case .familia: return String(localized: "ideas.category.familia")
        case .casa:    return String(localized: "ideas.category.casa")
        case .otro:    return String(localized: "ideas.category.otro")
        }
    }

    var systemImage: String {
        switch self {
        case .idea:    return "lightbulb.fill"
        case .tramite: return "doc.text.fill"
        case .familia: return "person.2.fill"
        case .casa:    return "house.fill"
        case .otro:    return "ellipsis"
        }
    }
}