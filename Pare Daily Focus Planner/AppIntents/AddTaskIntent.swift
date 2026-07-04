// AddTaskIntent.swift
// Intención de App para agregar una nueva tarea rápida. Permite añadir tareas a través de Siri, Spotlight o Shortcuts.

import AppIntents

struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Agregar Tarea"
    static var description = IntentDescription("Agrega una nueva tarea a tu lista de hoy en Pare.")

    @Parameter(title: "Título de la tarea")
    var title: String

    func perform() async throws -> some IntentResult {
        // Aquí normalmente se agregaría la tarea usando el modelo de datos o un servicio
        // Por ejemplo: TaskRepository.shared.addTask(title: title)
        // Esta implementación es un placeholder/demo
        return .result()
    }
}
