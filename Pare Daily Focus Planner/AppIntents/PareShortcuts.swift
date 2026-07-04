// PareShortcuts.swift
// Colección de atajos principales expuestos para Siri/Shortcuts en Pare

import AppIntents

struct PareShortcuts: AppShortcutsProvider {
    
    static var shortcutTileColor: ShortcutTileColor = .grayGreen

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: [
                "Mostrar hoy en Pare\(.applicationName)",
                "Ver mis tareas de hoy en \(.applicationName)"
            ],
            shortTitle: "Hoy",
            systemImageName: "calendar"
        )
    }
}
