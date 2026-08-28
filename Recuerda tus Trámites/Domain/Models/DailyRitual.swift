// DailyRitual.swift — SwiftData Model
import Foundation
import SwiftData

// MARK: - DailyRitual

@Model
final class DailyRitual {
    var id: UUID
    var date: Date                    // día al que pertenece (startOfDay)
    var typeRaw: String               // "morning" | "evening"
    var completedAt: Date
    var intentionTaskID: UUID?        // tarea elegida en morning
    var eveningNote: String?          // nota libre del cierre
    var carriedOverTaskIDs: [UUID]    // tareas pospuestas en evening

    var type: RitualType {
        get { RitualType(rawValue: typeRaw) ?? .morning }
        set { typeRaw = newValue.rawValue }
    }

    init(date: Date, type: RitualType) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.typeRaw = type.rawValue
        self.completedAt = Date()
        self.carriedOverTaskIDs = []
    }
}

// MARK: - RitualType

enum RitualType: String, Codable {
    case morning
    case evening
}
