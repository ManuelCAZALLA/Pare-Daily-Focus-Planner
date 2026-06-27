// Task.swift — SwiftData Model
import Foundation
import SwiftData

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
    var recurrenceRaw: String? // Codable Recurrence serializada
    var notificationIDs: [String]
    var createdAt: Date
    var weekPlan: WeekPlan?

    init(
        title: String,
        scheduledDate: Date,
        priority: Priority = .medium
    ) {
        self.id = UUID()
        self.title = title
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.priority = priority
        self.notificationIDs = []
        self.createdAt = Date()
    }
}
