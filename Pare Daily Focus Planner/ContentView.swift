// ContentView.swift
import SwiftUI
import SwiftData
import RevenueCatUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchasesService.self) private var purchases
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenOnboardingPaywall") private var hasSeenOnboardingPaywall = false
    @State private var showOnboardingPaywall = false
    @State private var selectedTab = 0
    
    var body: some View {
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
            guard !hasSeenOnboardingPaywall, !purchases.isProActive else { return }
            hasSeenOnboardingPaywall = true
            showOnboardingPaywall = true
        }
        .fullScreenCover(isPresented: $showOnboardingPaywall) {
            PaywallView()
                .onPurchaseCompleted { _ in
                    showOnboardingPaywall = false
                }
                .onRestoreCompleted { _ in
                    showOnboardingPaywall = false
                }
                .preferredColorScheme(.dark)
        }
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
                SettingsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("settings.title", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(Color.pareGreen)

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
        guard url.scheme == "pare" else { return }
        switch url.host {
        case "today":
            selectedTab = 0
        case "routine":
            selectedTab = 1
        case "obligations":
            selectedTab = 2
        default:
            break
        }
    }
}
