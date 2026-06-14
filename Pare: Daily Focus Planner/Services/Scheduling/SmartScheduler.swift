// SmartScheduler.swift
// Lógica de avisos inteligentes — sugiere cuándo y qué planificar
import Foundation

struct SmartScheduler {

    /// Devuelve sugerencias de tareas para mover/recordar basadas en patrones
    static func suggestions(from tasks: [PareTask], for date: Date) -> [PareTask] {
        tasks
            .filter { !$0.isCompleted && $0.scheduledDate < date }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    /// Notificación de revisión semanal — domingo a las 20:00
    static func weeklyReviewDate() -> Date {
        var comps = Calendar.current.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        comps.weekday = 1   // Domingo
        comps.hour    = 20
        comps.minute  = 0
        return Calendar.current.date(from: comps) ?? Date()
    }

    /// Notificación matutina configurable
    static func morningReminderDate(hour: Int = 8, minute: Int = 0) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }
}
