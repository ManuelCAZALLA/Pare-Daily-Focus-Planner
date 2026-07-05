// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("Hoy", systemImage: "sun.max.fill")
                }

            PomodoroView()
                .tabItem {
                    Label("Enfoque", systemImage: "timer")
                }

            WeekView()
                .tabItem {
                    Label("Semana", systemImage: "calendar")
                }

            StatsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.pareGreen)
        .preferredColorScheme(.dark)
    }
}
