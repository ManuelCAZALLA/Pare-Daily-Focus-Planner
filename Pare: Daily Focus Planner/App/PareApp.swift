// PareApp.swift
import SwiftUI
import SwiftData

@main
struct PareApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PareModelContainer.shared)
    }
}
