// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            PomodoroView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            WeekView()
                .tabItem {
                    Label("Week", systemImage: "calendar")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.pareGreen)
        .preferredColorScheme(.dark)
    }
}
