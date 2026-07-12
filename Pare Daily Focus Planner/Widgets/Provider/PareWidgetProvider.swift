import WidgetKit
import SwiftUI

struct PareWidgetEntry: TimelineEntry {
    let date: Date
    let task: PareWidgetTask?
    let completedCount: Int
    let totalCount: Int

    static let placeholder = PareWidgetEntry(
        date: .now,
        task: PareWidgetTask(title: "Preparar la reunión", time: "09:30", priority: .high),
        completedCount: 2,
        totalCount: 5
    )
}

struct PareWidgetTask: Hashable {
    let title: String
    let time: String?
    let priority: Priority
}

struct PareWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PareWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PareWidgetEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PareWidgetEntry>) -> Void) {
        // El widget se actualiza regularmente aunque no haya tareas pendientes.
        let entry = PareWidgetEntry(date: .now, task: nil, completedCount: 0, totalCount: 0)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}
