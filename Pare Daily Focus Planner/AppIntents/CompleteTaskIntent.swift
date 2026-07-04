// CompleteTaskIntent.swift
// Intención de App para marcar una tarea como completada desde Siri, Spotlight o Shortcuts.

import AppIntents

struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Completar tarea"
    static var description = IntentDescription("Marca una tarea como completada en Pare.")

    @Parameter(title: "ID de la tarea")
    var taskID: String

    func perform() async throws -> some IntentResult {
        // Aquí se marcaría la tarea como completada usando el repositorio/modelo de datos
        // Ejemplo: TaskRepository.shared.completeTask(withID: taskID)
        // Esta implementación es de demostración
        return .result()
    }
}
