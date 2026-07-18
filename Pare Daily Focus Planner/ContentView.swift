// ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            NavigationStack {
                DayView()
            }
            .tabItem {
                Label("Hoy", systemImage: "sun.max.fill")
            }

            NavigationStack {
                RoutineView()
            }
            .tabItem {
                Label("Rutina", systemImage: "moon.stars.fill")
            }

            NavigationStack {
                ObligationsView()
            }
            .tabItem {
                Label("Trámites", systemImage: "doc.text.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape.fill")
            }
        }
        .tint(Color.pareGreen)
        .preferredColorScheme(.dark)
    }
}
