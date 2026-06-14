// WeekPlan.swift — SwiftData Model
import Foundation
import SwiftData

@Model
final class WeekPlan {
    var id: UUID
    var weekStart: Date   // Siempre lunes a 00:00
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

    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter(\.isCompleted).count) / Double(tasks.count)
    }

    var isCurrentWeek: Bool {
        Calendar.current.isDate(weekStart, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
