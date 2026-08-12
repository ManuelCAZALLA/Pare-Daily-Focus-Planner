// PareModelContainer.swift
import Foundation
import SwiftData

enum PareAppGroup {
    static let id = "group.com.manuelcazalla.pare"

    /// Contenedor compartido con el widget (App Group)
    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            fatalError("PareModelContainer: App Group \(id) no disponible")
        }
        return url
    }

    static var storeURL: URL {
        containerURL.appendingPathComponent("pare.sqlite")
    }
}

enum PareModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([PareTask.self, WeekPlan.self, LifeObligation.self, DailyRitual.self, FamilyProfile.self])
        let config = ModelConfiguration(schema: schema, url: PareAppGroup.storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("PareModelContainer: no se pudo inicializar — \(error)")
        }
    }()

    /// Para previews y tests
    static let preview: ModelContainer = {
        let schema = Schema([PareTask.self, WeekPlan.self, LifeObligation.self, DailyRitual.self, FamilyProfile.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
