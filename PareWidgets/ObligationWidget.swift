// ObligationWidget.swift
import WidgetKit
import SwiftUI

struct ObligationWidget: Widget {
    let kind = "ObligationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PareWidgetProvider()) { entry in
            ProGatedWidgetContent {
                ObligationWidgetView(entry: entry)
            }
            .containerBackground(for: .widget) {
                WidgetBackground()
            }
        }
        .configurationDisplayName(String(localized: "widget.obligation.name"))
        .description(String(localized: "widget.obligation.description"))
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
