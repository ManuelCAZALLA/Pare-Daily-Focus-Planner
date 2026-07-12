import WidgetKit
import SwiftUI

struct PareWidget: Widget {
    let kind = "PareWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PareWidgetProvider()) { entry in
            PareWidgetView(entry: entry)
                .widgetURL(URL(string: "pare://today"))
        }
        .configurationDisplayName("Tu foco de hoy")
        .description("Consulta tu siguiente tarea y el progreso del día.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
