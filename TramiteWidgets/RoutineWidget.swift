// RoutineWidget.swift
import WidgetKit
import SwiftUI

struct RoutineWidget: Widget {
    let kind = "RoutineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TramiteWidgetProvider()) { entry in
            ProGatedWidgetContent {
                RoutineWidgetView(entry: entry)
            }
            .containerBackground(for: .widget) {
                WidgetBackground()
            }
        }
        .configurationDisplayName(String(localized: "widget.routine.name"))
        .description(String(localized: "widget.routine.description"))
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}
