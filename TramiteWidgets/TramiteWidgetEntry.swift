// TramiteWidgetEntry.swift
import Foundation
import WidgetKit

struct TramiteWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
    let urgentObligation: WidgetObligation?
    /// Hasta 2 trámites para la variante mediana
    let obligations: [WidgetObligation]
    let morningDone: Bool
    let eveningDone: Bool
    let streak: Int

    static let placeholder = TramiteWidgetEntry(
        date: .now,
        tasks: [
            WidgetTask(id: UUID(), title: "Preparar la reunión", isCompleted: false, priority: 3, scheduledTime: nil),
            WidgetTask(id: UUID(), title: "Enviar presupuesto", isCompleted: false, priority: 2, scheduledTime: nil),
            WidgetTask(id: UUID(), title: "Llamar al dentista", isCompleted: true, priority: 1, scheduledTime: nil)
        ],
        urgentObligation: WidgetObligation(id: UUID(), title: "ITV", daysRemaining: 12, categoryIcon: "car.fill", categoryName: String(localized: "Vehículo")),
        obligations: [
            WidgetObligation(id: UUID(), title: "ITV", daysRemaining: 12, categoryIcon: "car.fill", categoryName: String(localized: "Vehículo")),
            WidgetObligation(id: UUID(), title: "Seguro del coche", daysRemaining: 45, categoryIcon: "car.fill", categoryName: String(localized: "Vehículo"))
        ],
        morningDone: true,
        eveningDone: false,
        streak: 5
    )
}

struct WidgetTask: Identifiable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    /// 0 = baja, 1 = media, 2 = alta, 3 = imprescindible
    let priority: Int
    let scheduledTime: Date?
}

struct WidgetObligation: Identifiable {
    let id: UUID
    let title: String
    let daysRemaining: Int
    let categoryIcon: String
    let categoryName: String
}
