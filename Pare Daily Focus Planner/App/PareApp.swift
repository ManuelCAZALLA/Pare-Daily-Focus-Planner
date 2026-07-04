// PareApp.swift
import SwiftUI
import SwiftData

@main
struct PareApp: App {

    @State private var dayViewModel: DayViewModel
    @State private var weekViewModel: WeekViewModel
    @State private var pomodoroViewModel: PomodoroViewModel
    @State private var notificationService = NotificationService()

    init() {
        let context  = PareModelContainer.shared.mainContext
        let taskRepo = TaskRepository(context: context)
        let weekRepo = WeekPlanRepository(context: context)
        let focusRepo = FocusSessionRepository(context: context)

        _dayViewModel      = State(initialValue: DayViewModel(
            taskRepository: taskRepo,
            notificationService: NotificationService()
        ))
        _weekViewModel     = State(initialValue: WeekViewModel(
            weekPlanRepository: weekRepo,
            taskRepository: taskRepo
        ))
        _pomodoroViewModel = State(initialValue: PomodoroViewModel(
            repository: focusRepo
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dayViewModel)
                .environment(weekViewModel)
                .environment(pomodoroViewModel)
                .environment(notificationService)
        }
        .modelContainer(PareModelContainer.shared)
    }
}
