// PareModelContainer.swift
import Foundation
import SwiftData

enum PareAppGroup {
    static let id = "group.com.manuelcazalla.daysorted"

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
        let newURL = containerURL.appendingPathComponent("daysorted.sqlite")
        let oldURL = containerURL.appendingPathComponent("pare.sqlite")
        if !FileManager.default.fileExists(atPath: newURL.path) && FileManager.default.fileExists(atPath: oldURL.path) {
            try? FileManager.default.moveItem(at: oldURL, to: newURL)
            let oldWal = containerURL.appendingPathComponent("pare.sqlite-wal")
            let newWal = containerURL.appendingPathComponent("daysorted.sqlite-wal")
            if FileManager.default.fileExists(atPath: oldWal.path) {
                try? FileManager.default.moveItem(at: oldWal, to: newWal)
            }
            let oldShm = containerURL.appendingPathComponent("pare.sqlite-shm")
            let newShm = containerURL.appendingPathComponent("daysorted.sqlite-shm")
            if FileManager.default.fileExists(atPath: oldShm.path) {
                try? FileManager.default.moveItem(at: oldShm, to: newShm)
            }
        }
        return newURL
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
