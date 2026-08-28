// TaskRepository.swift
import Foundation
import SwiftData

final class TaskRepository: TaskRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func tasks(for date: Date) -> [TramiteTask] {
        let start = Calendar.current.startOfDay(for: date)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let pred  = #Predicate<TramiteTask> { $0.scheduledDate >= start && $0.scheduledDate < end }
        return (try? context.fetch(FetchDescriptor(predicate: pred))) ?? []
    }

    func allPending() -> [TramiteTask] {
        let pred = #Predicate<TramiteTask> { !$0.isCompleted }
        return (try? context.fetch(FetchDescriptor(predicate: pred))) ?? []
    }

    func save(_ task: TramiteTask) throws {
        context.insert(task)
        try context.save()
    }

    func delete(_ task: TramiteTask) throws {
        context.delete(task)
        try context.save()
    }

    func complete(_ task: TramiteTask) throws {
        task.isCompleted = true
        task.completedAt = Date()
        try context.save()
    }
}
