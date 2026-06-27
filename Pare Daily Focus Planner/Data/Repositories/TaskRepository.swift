// TaskRepository.swift
import Foundation
import SwiftData

final class TaskRepository: TaskRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func tasks(for date: Date) -> [PareTask] {
        let start = Calendar.current.startOfDay(for: date)
        let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let pred  = #Predicate<PareTask> { $0.scheduledDate >= start && $0.scheduledDate < end }
        return (try? context.fetch(FetchDescriptor(predicate: pred))) ?? []
    }

    func allPending() -> [PareTask] {
        let pred = #Predicate<PareTask> { !$0.isCompleted }
        return (try? context.fetch(FetchDescriptor(predicate: pred))) ?? []
    }

    func save(_ task: PareTask) throws {
        context.insert(task)
        try context.save()
    }

    func delete(_ task: PareTask) throws {
        context.delete(task)
        try context.save()
    }

    func complete(_ task: PareTask) throws {
        task.isCompleted = true
        task.completedAt = Date()
        try context.save()
    }
}
