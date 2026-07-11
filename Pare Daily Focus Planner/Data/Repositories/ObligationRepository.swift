// ObligationRepository.swift
import Foundation
import SwiftData

final class ObligationRepository: ObligationRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() -> [LifeObligation] {
        let descriptor = FetchDescriptor<LifeObligation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func obligation(forTemplateID templateID: String) -> LifeObligation? {
        let pred = #Predicate<LifeObligation> { $0.templateID == templateID }
        return try? context.fetch(FetchDescriptor(predicate: pred)).first
    }

    func save(_ obligation: LifeObligation) throws {
        obligation.updatedAt = Date()
        if obligation.modelContext == nil {
            context.insert(obligation)
        }
        try context.save()
    }

    func delete(_ obligation: LifeObligation) throws {
        context.delete(obligation)
        try context.save()
    }
}
