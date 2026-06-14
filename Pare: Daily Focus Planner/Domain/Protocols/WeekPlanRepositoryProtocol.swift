// WeekPlanRepositoryProtocol.swift
import Foundation

protocol WeekPlanRepositoryProtocol {
    func currentWeekPlan() -> WeekPlan?
    func weekPlan(for date: Date) -> WeekPlan?
    func createWeekPlan(starting: Date) throws -> WeekPlan
    func save(_ plan: WeekPlan) throws
}
