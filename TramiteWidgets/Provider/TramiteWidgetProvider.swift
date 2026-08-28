// TramiteWidgetProvider.swift
import WidgetKit
import SwiftUI

struct TramiteWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TramiteWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TramiteWidgetEntry) -> Void) {
        Task { @MainActor in
            completion(TramiteWidgetDataLoader().load() ?? .placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TramiteWidgetEntry>) -> Void) {
        Task { @MainActor in
            let entry = TramiteWidgetDataLoader().load() ?? .placeholder
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }
}
