// WidgetModels.swift
// Modelos espejo de la app para poder leer el mismo almacén SwiftData
// desde el widget (mismo esquema, mismos nombres de entidad y propiedades).
import Foundation
import SwiftData

// MARK: - Enums

enum Priority: Int, Codable, CaseIterable {
    case low    = 0
    case medium = 1
    case high   = 2
    case must   = 3
}

enum RitualType: String, Codable {
    case morning
    case evening
}

// MARK: - Modelos

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
    var recurrenceRaw: String?
    var notificationIDs: [String]
    var alertOffsetRaw: Double?
    var createdAt: Date
    var weekPlan: WeekPlan?

    init(title: String, scheduledDate: Date, priority: Priority = .medium) {
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

@Model
final class WeekPlan {
    var id: UUID
    var weekStart: Date
    var weekNote: String?
    var createdAt: Date
    var reviewedAt: Date?
    @Relationship(deleteRule: .cascade) var tasks: [PareTask]

    init(weekStart: Date) {
        self.id = UUID()
        self.weekStart = weekStart
        self.tasks = []
        self.createdAt = Date()
    }
}

@Model
final class LifeObligation {
    var id: UUID
    var templateID: String
    var holderName: String?
    var expiryDate: Date?
    var actionStartDate: Date?
    var notes: String?
    var location: String?
    var estimatedCost: String?
    var documentsNeeded: String?
    @Attribute(.externalStorage) var scannedDocumentData: Data?
    var escalatedAlertsEnabled: Bool
    var notificationIDs: [String]
    var alertOffsetRaw: String?
    var createdAt: Date
    var updatedAt: Date
    var familyProfile: FamilyProfile?

    init(templateID: String) {
        self.id = UUID()
        self.templateID = templateID
        self.notificationIDs = []
        self.alertOffsetRaw = nil
        self.escalatedAlertsEnabled = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class DailyRitual {
    var id: UUID
    var date: Date
    var typeRaw: String
    var completedAt: Date
    var intentionTaskID: UUID?
    var eveningNote: String?
    var carriedOverTaskIDs: [UUID]

    init(date: Date, type: RitualType) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.typeRaw = type.rawValue
        self.completedAt = Date()
        self.carriedOverTaskIDs = []
    }
}

@Model
final class FamilyProfile {
    var id: UUID
    var name: String
    var relationship: String
    var colorHex: String
    var avatar: String

    @Relationship(deleteRule: .cascade)
    var obligations: [LifeObligation]?

    init(id: UUID = UUID(), name: String, relationship: String, colorHex: String, avatar: String) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.colorHex = colorHex
        self.avatar = avatar
    }
}

// MARK: - Plantillas de trámites (para título e icono de categoría)

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

struct ObligationTemplate: Identifiable, Hashable {
    let id: String
    let category: LifeAdminCategory
    let title: String
    let contextHint: String?

    static let all: [ObligationTemplate] = [
        // Personal documents
        .init(id: "dni", category: .personalDocuments, title: String(localized: "DNI / NIE"), contextHint: nil),
        .init(id: "passport", category: .personalDocuments, title: String(localized: "Pasaporte"), contextHint: nil),
        .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Carnet de conducir"), contextHint: nil),
        .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta sanitaria"), contextHint: nil),
        .init(id: "residence_permit", category: .personalDocuments, title: String(localized: "Permiso de residencia"), contextHint: nil),
        .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado digital (FNMT)"), contextHint: nil),
        .init(id: "degree_homologation", category: .personalDocuments, title: String(localized: "Título universitario homologado"), contextHint: nil),

        // Vehicle
        .init(id: "itv", category: .vehicle, title: String(localized: "ITV"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
        .init(id: "car_insurance", category: .vehicle, title: String(localized: "Seguro del coche"), contextHint: nil),
        .init(id: "moto_insurance", category: .vehicle, title: String(localized: "Seguro de moto"), contextHint: nil),
        .init(id: "workshop_review", category: .vehicle, title: String(localized: "Revisión del taller"), contextHint: nil),
        .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Permiso de circulación"), contextHint: nil),
        .init(id: "foreign_license", category: .vehicle, title: String(localized: "Licencia de conducir extranjera"), contextHint: nil),

        // Home
        .init(id: "home_insurance", category: .home, title: String(localized: "Seguro del hogar"), contextHint: nil),
        .init(id: "rental_contract", category: .home, title: String(localized: "Contrato de alquiler"), contextHint: nil),
        .init(id: "boiler_review", category: .home, title: String(localized: "Caldera (revisión anual)"), contextHint: nil),
        .init(id: "fire_extinguisher", category: .home, title: String(localized: "Extintor"), contextHint: nil),
        .init(id: "energy_certificate", category: .home, title: String(localized: "Certificado energético"), contextHint: nil),
        .init(id: "hoa_fees", category: .home, title: String(localized: "Comunidad de vecinos"), contextHint: nil),

        // Health
        .init(id: "annual_checkup", category: .health, title: String(localized: "Revisión médica anual"), contextHint: nil),
        .init(id: "vaccines", category: .health, title: String(localized: "Vacunas"), contextHint: nil),
        .init(id: "private_health_insurance", category: .health, title: String(localized: "Seguro médico privado"), contextHint: nil),
        .init(id: "eye_exam", category: .health, title: String(localized: "Revisión óptica"), contextHint: nil),
        .init(id: "dentist", category: .health, title: String(localized: "Dentista"), contextHint: nil),
        .init(id: "gynecology", category: .health, title: String(localized: "Revisión ginecológica"), contextHint: nil),

        // Finance
        .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de la Renta"), contextHint: nil),
        .init(id: "credit_card", category: .finance, title: String(localized: "Tarjeta de crédito"), contextHint: nil),
        .init(id: "life_insurance", category: .finance, title: String(localized: "Seguro de vida"), contextHint: nil),
        .init(id: "pension_plan", category: .finance, title: String(localized: "Plan de pensiones"), contextHint: nil),
        .init(id: "annual_subscriptions", category: .finance, title: String(localized: "Suscripciones anuales"), contextHint: nil),
        .init(id: "freelance_fees", category: .finance, title: String(localized: "Cuotas de autónomo"), contextHint: nil),

        // Work
        .init(id: "professional_cert", category: .work, title: String(localized: "Certificaciones profesionales"), contextHint: nil),
        .init(id: "professional_college", category: .work, title: String(localized: "Colegio profesional"), contextHint: nil),
        .init(id: "transport_card", category: .work, title: String(localized: "Tarjeta de transporte"), contextHint: nil),
        .init(id: "work_permit", category: .work, title: String(localized: "Permiso de trabajo"), contextHint: nil),
        .init(id: "expiring_courses", category: .work, title: String(localized: "Cursos con caducidad"), contextHint: nil),
    ]
}
