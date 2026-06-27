// WeekViewModel.swift
import Foundation
import SwiftData

@Observable
final class WeekViewModel {
    private let weekPlanRepository: WeekPlanRepositoryProtocol
    private let taskRepository: TaskRepositoryProtocol

    var currentPlan: WeekPlan?
    var tasksByDay: [Date: [PareTask]] = [:]
    var weekDates: [Date] = []

    init(weekPlanRepository: WeekPlanRepositoryProtocol, taskRepository: TaskRepositoryProtocol) {
        self.weekPlanRepository = weekPlanRepository
        self.taskRepository = taskRepository
    }
}
