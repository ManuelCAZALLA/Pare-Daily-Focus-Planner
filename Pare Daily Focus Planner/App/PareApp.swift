// PareApp.swift
import SwiftUI
import SwiftData

@main
struct PareApp: App {

    @State private var dayViewModel: DayViewModel
    @State private var routineViewModel: RoutineViewModel
    @State private var obligationsViewModel: ObligationsViewModel
    @State private var notificationService = NotificationService()

    init() {
        let context  = PareModelContainer.shared.mainContext
        let taskRepo = TaskRepository(context: context)
        let obligationsRepo = ObligationRepository(context: context)
        let notifications = NotificationService()

        _dayViewModel      = State(initialValue: DayViewModel(
            taskRepository: taskRepo,
            notificationService: notifications
        ))
        _routineViewModel  = State(initialValue: RoutineViewModel(
            context: context,
            taskRepository: taskRepo
        ))
        _obligationsViewModel = State(initialValue: ObligationsViewModel(
            repository: obligationsRepo,
            notificationService: notifications
        ))
        _notificationService = State(initialValue: notifications)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dayViewModel)
                .environment(routineViewModel)
                .environment(obligationsViewModel)
                .environment(notificationService)
        }
        .modelContainer(PareModelContainer.shared)
    }
}
