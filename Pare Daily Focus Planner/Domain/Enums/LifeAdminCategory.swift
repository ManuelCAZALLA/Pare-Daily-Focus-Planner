// LifeAdminCategory.swift
import Foundation

enum LifeAdminCategory: String, CaseIterable, Identifiable, Codable {
    case personalDocuments
    case vehicle
    case home
    case health
    case finance
    case work

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personalDocuments: return String(localized: "Documentos personales")
        case .vehicle:           return String(localized: "Vehículo")
        case .home:              return String(localized: "Hogar")
        case .health:            return String(localized: "Salud")
        case .finance:           return String(localized: "Finanzas")
        case .work:              return String(localized: "Trabajo y formación")
        }
    }

    var systemImage: String {
        switch self {
        case .personalDocuments: return "person.text.rectangle"
        case .vehicle:           return "car.fill"
        case .home:              return "house.fill"
        case .health:            return "heart.text.clipboard"
        case .finance:           return "eurosign.circle.fill"
        case .work:              return "briefcase.fill"
        }
    }

    var items: [ObligationTemplate] {
        ObligationTemplate.all.filter { $0.category == self }
    }
}
