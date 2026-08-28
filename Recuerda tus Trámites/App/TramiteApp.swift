// TramiteApp.swift
import SwiftUI
import SwiftData
import RevenueCat

@main
struct TramiteApp: App {

    @State private var dayViewModel: DayViewModel
    @State private var routineViewModel: RoutineViewModel
    @State private var obligationsViewModel: ObligationsViewModel
    @State private var notificationService = NotificationService()

    init() {
        let context  = TramiteModelContainer.shared.mainContext
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
            notificationService: notifications,
            purchasesService: PurchasesService.shared
        ))
        _notificationService = State(initialValue: notifications)

        // ── RevenueCat ──────────────────────────────────────────────────
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: RevenueCatConfig.apiKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dayViewModel)
                .environment(routineViewModel)
                .environment(obligationsViewModel)
                .environment(notificationService)
                .environment(PurchasesService.shared)   // ← Pro status global
        }
        .modelContainer(TramiteModelContainer.shared)
    }
}
