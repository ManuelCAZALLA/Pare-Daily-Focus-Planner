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
    
    var body: some View {
        Group {
            if hasSeenOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
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
        let tabView = TabView {
            NavigationStack {
                DayView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("Hoy", systemImage: "sun.max.fill")
            }

            NavigationStack {
                RoutineView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("Rutina", systemImage: "moon.stars.fill")
            }

            NavigationStack {
                ObligationsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("obligations.title", systemImage: "doc.text.fill")
            }

            NavigationStack {
                SettingsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("settings.title", systemImage: "gearshape.fill")
            }
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
}
