// ShowTodayIntent.swift
// Intención de App para mostrar la pantalla de hoy en el app. Esta intención puede ser invocada por Siri, Spotlight o Shortcuts para abrir la vista principal del día.

import AppIntents

struct ShowTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Mostrar Hoy"
    static var description = IntentDescription("Abre la pantalla de tareas del día de hoy en Pare.")

    func perform() async throws -> some IntentResult {
        // Aquí normalmente se invoca la lógica para navegar o activar la pantalla de hoy
        // La implementación concreta depende de cómo la app maneje deep links o navegación
        return .result()
    }
}
