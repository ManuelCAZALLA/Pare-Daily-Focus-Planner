// WeekPlanRepository.swift
import Foundation
import SwiftData

final class WeekPlanRepository: WeekPlanRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func currentWeekPlan() -> WeekPlan? {
        weekPlan(for: Date())
    }

    func weekPlan(for date: Date) -> WeekPlan? {
        let monday = date.startOfWeek
        let pred = #Predicate<WeekPlan> { $0.weekStart == monday }
        return try? context.fetch(FetchDescriptor(predicate: pred)).first
    }

    func createWeekPlan(starting monday: Date) throws -> WeekPlan {
        let plan = WeekPlan(weekStart: monday)
        context.insert(plan)
        try context.save()
        return plan
    }

    func save(_ plan: WeekPlan) throws {
        try context.save()
    }
}
