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
    var createdAt: Date
    var updatedAt: Date

    init(templateID: String) {
        self.id = UUID()
        self.templateID = templateID
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
