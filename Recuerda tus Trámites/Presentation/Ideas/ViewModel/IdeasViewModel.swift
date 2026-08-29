// IdeasViewModel.swift
import Foundation

@Observable
@MainActor
final class IdeasViewModel {
    private let repository: IdeaRepositoryProtocol

    var ideas: [TramiteIdea] = []
    var selectedCategory: IdeaCategory? = nil

    init(repository: IdeaRepositoryProtocol) {
        self.repository = repository
    }

    /// Ideas ordenadas para el muro: ancladas primero, luego por creación.
    var displayedIdeas: [TramiteIdea] {
        let filtered = selectedCategory.map { category in
            ideas.filter { $0.category == category }
        } ?? ideas

        return filtered.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            return lhs.createdAt > rhs.createdAt
        }
    }

    func load() {
        ideas = repository.all()
    }

    @discardableResult
    func add(text: String, category: IdeaCategory) -> TramiteIdea? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let idea = TramiteIdea(text: trimmed, category: category)
        try? repository.save(idea)
        load()
        return idea
    }

    func update(_ idea: TramiteIdea, text: String, category: IdeaCategory) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        idea.text = trimmed
        idea.category = category
        try? repository.save(idea)
        load()
    }

    func togglePin(_ idea: TramiteIdea) {
        idea.isPinned.toggle()
        try? repository.save(idea)
        load()
    }

    func delete(_ idea: TramiteIdea) {
        try? repository.delete(idea)
        load()
    }

    func contains(_ idea: TramiteIdea) -> Bool {
        ideas.contains { $0.id == idea.id }
    }
}