// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        Group {
            if hasSeenOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
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
                Label("Trámites", systemImage: "doc.text.fill")
            }

            NavigationStack {
                SettingsView()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape.fill")
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
