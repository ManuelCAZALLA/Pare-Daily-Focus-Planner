// TodayWidget.swift
import WidgetKit
import SwiftUI

struct TodayWidget: Widget {
    let kind = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PareWidgetProvider()) { entry in
            ProGatedWidgetContent {
                TodayWidgetView(entry: entry)
            }
            .containerBackground(for: .widget) {
                WidgetBackground()
            }
        }
        .configurationDisplayName(String(localized: "widget.today.name"))
        .description(String(localized: "widget.today.description"))
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
