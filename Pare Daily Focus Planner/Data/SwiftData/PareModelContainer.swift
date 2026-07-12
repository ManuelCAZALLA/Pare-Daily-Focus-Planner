// PareModelContainer.swift
import SwiftData

enum PareModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([PareTask.self, WeekPlan.self, LifeObligation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("PareModelContainer: no se pudo inicializar — \(error)")
        }
    }()

    /// Para previews y tests
    static let preview: ModelContainer = {
        let schema = Schema([PareTask.self, WeekPlan.self, LifeObligation.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
