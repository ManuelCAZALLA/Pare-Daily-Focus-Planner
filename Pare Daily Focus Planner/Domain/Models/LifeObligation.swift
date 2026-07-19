// LifeObligation.swift
import Foundation
import SwiftData

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
    var notificationIDs: [String] = []
    var alertOffsetRaw: String?
    var createdAt: Date
    var updatedAt: Date
    var familyProfile: FamilyProfile?

    var alertOffset: ObligationAlertOffset? {
        get {
            guard let raw = alertOffsetRaw else { return nil }
            return ObligationAlertOffset(rawValue: raw)
        }
        set {
            alertOffsetRaw = newValue?.rawValue
        }
    }

    init(templateID: String) {
        self.id = UUID()
        self.templateID = templateID
        self.notificationIDs = []
        self.alertOffsetRaw = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var daysUntilExpiry: Int? {
        guard let expiryDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: start, to: end).day
    }
}

enum ObligationAlertOffset: String, CaseIterable, Identifiable, Codable {
    case oneMonth
    case twoWeeks
    case oneWeek
    case twoDays
    case onExpiry

    var id: String { rawValue }

    var label: String {
        switch self {
        case .oneMonth: return String(localized: "1 mes antes")
        case .twoWeeks: return String(localized: "2 semanas antes")
        case .oneWeek: return String(localized: "1 semana antes")
        case .twoDays: return String(localized: "2 días antes")
        case .onExpiry: return String(localized: "El día de vencimiento")
        }
    }

    var timeIntervalBefore: TimeInterval {
        switch self {
        case .oneMonth: return 30 * 24 * 60 * 60
        case .twoWeeks: return 14 * 24 * 60 * 60
        case .oneWeek: return 7 * 24 * 60 * 60
        case .twoDays: return 2 * 24 * 60 * 60
        case .onExpiry: return 0
        }
    }
}
