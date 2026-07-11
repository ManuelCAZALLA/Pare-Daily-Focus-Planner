// PareApp.swift
import SwiftUI
import SwiftData

@main
struct PareApp: App {

    @State private var dayViewModel: DayViewModel
    @State private var pomodoroViewModel: PomodoroViewModel
    @State private var obligationsViewModel: ObligationsViewModel
    @State private var notificationService = NotificationService()

    init() {
        let context  = PareModelContainer.shared.mainContext
        let taskRepo = TaskRepository(context: context)
        let focusRepo = FocusSessionRepository(context: context)
        let obligationsRepo = ObligationRepository(context: context)

        _dayViewModel      = State(initialValue: DayViewModel(
            taskRepository: taskRepo,
            notificationService: NotificationService()
        ))
        _pomodoroViewModel = State(initialValue: PomodoroViewModel(
            repository: focusRepo
        ))
        _obligationsViewModel = State(initialValue: ObligationsViewModel(repository: obligationsRepo))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dayViewModel)
                .environment(pomodoroViewModel)
                .environment(obligationsViewModel)
                .environment(notificationService)
        }
        .modelContainer(PareModelContainer.shared)
    }
}
