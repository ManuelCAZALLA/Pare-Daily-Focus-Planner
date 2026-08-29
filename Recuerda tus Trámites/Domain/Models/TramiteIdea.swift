// TramiteIdea.swift — SwiftData Model
import Foundation
import SwiftData

@Model
final class TramiteIdea {
    var id: UUID
    var text: String
    var categoryRaw: String  // IdeaCategory serializada
    var isPinned: Bool
    var createdAt: Date

    var category: IdeaCategory {
        get { IdeaCategory(rawValue: categoryRaw) ?? .idea }
        set { categoryRaw = newValue.rawValue }
    }

    init(text: String, category: IdeaCategory) {
        self.id = UUID()
        self.text = text
        self.categoryRaw = category.rawValue
        self.isPinned = false
        self.createdAt = Date()
    }
}