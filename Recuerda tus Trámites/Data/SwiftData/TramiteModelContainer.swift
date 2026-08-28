// TramiteModelContainer.swift
import Foundation
import SwiftData

enum TramiteAppGroup {
    static let id = "group.com.manuelcazalla.recuerdatustramites"

    /// Contenedor compartido con el widget (App Group)
    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            fatalError("TramiteModelContainer: App Group \(id) no disponible")
        }
        return url
    }

    static var storeURL: URL {
        let newURL = containerURL.appendingPathComponent("recuerdatustramites.sqlite")
        if FileManager.default.fileExists(atPath: newURL.path) {
            return newURL
        }
        let daySortedURL = containerURL.appendingPathComponent("daysorted.sqlite")
        migrate(from: daySortedURL, to: newURL)
        if FileManager.default.fileExists(atPath: newURL.path) {
            return newURL
        }
        let pareURL = containerURL.appendingPathComponent("pare.sqlite")
        migrate(from: pareURL, to: newURL)
        return newURL
    }

    private static func migrate(from oldURL: URL, to newURL: URL) {
        guard !FileManager.default.fileExists(atPath: newURL.path),
              FileManager.default.fileExists(atPath: oldURL.path) else { return }
        try? FileManager.default.moveItem(at: oldURL, to: newURL)
        for suffix in ["-wal", "-shm"] {
            let oldSidecar = containerURL.appendingPathComponent(oldURL.lastPathComponent + suffix)
            let newSidecar = containerURL.appendingPathComponent(newURL.lastPathComponent + suffix)
            if FileManager.default.fileExists(atPath: oldSidecar.path) {
                try? FileManager.default.moveItem(at: oldSidecar, to: newSidecar)
            }
        }
    }
}

enum TramiteModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([TramiteTask.self, WeekPlan.self, LifeObligation.self, DailyRitual.self, FamilyProfile.self])
        let config = ModelConfiguration(schema: schema, url: TramiteAppGroup.storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("TramiteModelContainer: no se pudo inicializar — \(error)")
        }
    }()

    /// Para previews y tests
    static let preview: ModelContainer = {
        let schema = Schema([TramiteTask.self, WeekPlan.self, LifeObligation.self, DailyRitual.self, FamilyProfile.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}