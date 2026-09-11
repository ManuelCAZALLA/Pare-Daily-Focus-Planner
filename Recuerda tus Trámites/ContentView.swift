// ContentView.swift
import SwiftUI
import SwiftData
import RevenueCatUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchasesService.self) private var purchases
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenOnboardingPaywall") private var hasSeenOnboardingPaywall = false
    @State private var selectedTab = 0
    @State private var purchaseErrorMessage: String?
    
    var body: some View {
        @Bindable var purchases = purchases
        Group {
            if hasSeenOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
        .onOpenURL(perform: handleDeepLink)
        .task {
            await purchases.loadCustomerInfo()
            await maybeShowOnboardingPaywall()
        }
        .onChange(of: hasSeenOnboarding) { _, completed in
            guard completed else { return }
            Task { await maybeShowOnboardingPaywall() }
        }
        .fullScreenCover(isPresented: $purchases.showPaywall) {
            PaywallView(displayCloseButton: true)
                .onPurchaseCompleted { customerInfo in
                    purchases.customerInfo = customerInfo
                    hasSeenOnboardingPaywall = true
                    purchases.showPaywall = false
                }
                .onRestoreCompleted { customerInfo in
                    purchases.customerInfo = customerInfo
                    hasSeenOnboardingPaywall = true
                    purchases.showPaywall = false
                }
                .onPurchaseFailure { error in
                    // No mostramos el alert crudo de StoreKit ("Purchase was cancelled").
                    // En sandbox (revisión de Apple) un fallo suele deberse a Error 11
                    // (InvalidCredentialsError), un problema de configuración del bundle ID
                    // o la API key de RevenueCat, no de la UI.
                    purchaseErrorMessage = failureMessage(for: error)
                }
                .preferredColorScheme(.dark)
        }
        .alert(
            "No se pudo completar la compra",
            isPresented: Binding(
                get: { purchaseErrorMessage != nil },
                set: { if !$0 { purchaseErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { purchaseErrorMessage = nil }
        } message: {
            Text(purchaseErrorMessage ?? "")
        }
    }

    /// Muestra el paywall de onboarding una única vez, tras verificar el estado Pro.
    /// NUNCA lo muestra mientras el usuario está aún en el flujo de Onboarding inicial (hasSeenOnboarding == false).
    /// Espera 600ms tras la inicialización para permitir que UIWindowScene y sidebarAdaptable en iPadOS estén asentados.
    @MainActor
    private func maybeShowOnboardingPaywall() async {
        guard !purchases.isProActive else { return }
        guard !hasSeenOnboardingPaywall else { return }
        guard hasSeenOnboarding else { return }
        
        try? await Task.sleep(for: .milliseconds(600))
        purchases.showPaywall = true
    }

    @ViewBuilder
    private var mainTabView: some View {
        let tabView = TabView(selection: $selectedTab) {
            NavigationStack {
                DayView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("Hoy", systemImage: "sun.max.fill")
            }
            .tag(0)

            NavigationStack {
                RoutineView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("Rutina", systemImage: "moon.stars.fill")
            }
            .tag(1)

            NavigationStack {
                ObligationsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("obligations.title", systemImage: "doc.text.fill")
            }
            .tag(2)

            NavigationStack {
                IdeasView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("ideas.title", systemImage: "lightbulb.fill")
            }
            .tag(3)

            NavigationStack {
                SettingsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("settings.title", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(Color.tramiteGreen)

        #if os(iOS) || os(macOS)
        if #available(iOS 18.0, macOS 15.0, *) {
            tabView
                .tabViewStyle(.sidebarAdaptable)
        } else {
            tabView
        }
        #else
        tabView
        #endif
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "recuerdatustramites" else { return }
        switch url.host {
        case "today":
            selectedTab = 0
        case "routine":
            selectedTab = 1
        case "obligations":
            selectedTab = 2
        case "ideas":
            selectedTab = 3
        default:
            break
        }
    }

    /// Convierte un error de compra de RevenueCat en un mensaje útil para el usuario,
    /// evitando mostrar el texto críptico que ve el revisor de Apple en sandbox.
    private func failureMessage(for error: Error) -> String {
        let ns = error as NSError
        if ns.code == 11 || ns.localizedDescription.localizedCaseInsensitiveContains("credentials") || ns.localizedDescription.localizedCaseInsensitiveContains("invalid api key") {
            return "No se ha podido conectar con la tienda. Vuelve a intentarlo en unos minutos."
        }
        if ns.code == 2 || ns.localizedDescription.localizedCaseInsensitiveContains("cancel") {
            return "Has cancelado la compra."
        }
        return "No se ha podido completar la compra. Inténtalo de nuevo."
    }
}
