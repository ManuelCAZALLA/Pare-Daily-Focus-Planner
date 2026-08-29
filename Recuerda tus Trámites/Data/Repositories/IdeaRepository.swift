// IdeaRepository.swift
import Foundation
import SwiftData

final class IdeaRepository: IdeaRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func all() -> [TramiteIdea] {
        (try? context.fetch(FetchDescriptor<TramiteIdea>())) ?? []
    }

    func save(_ idea: TramiteIdea) throws {
        context.insert(idea)
        try context.save()
    }

    func delete(_ idea: TramiteIdea) throws {
        context.delete(idea)
        try context.save()
    }
}