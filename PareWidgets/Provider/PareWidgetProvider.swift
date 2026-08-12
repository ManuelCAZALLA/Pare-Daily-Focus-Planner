// PareWidgetProvider.swift
import WidgetKit
import SwiftUI

struct PareWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PareWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PareWidgetEntry) -> Void) {
        Task { @MainActor in
            completion(PareWidgetDataLoader().load() ?? .placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PareWidgetEntry>) -> Void) {
        Task { @MainActor in
            let entry = PareWidgetDataLoader().load() ?? .placeholder
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }
}
