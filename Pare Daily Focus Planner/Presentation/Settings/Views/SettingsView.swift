// SettingsView.swift
// Presentation/Settings/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.pareGreen.opacity(0.4))
                Text("Ajustes")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("Próximamente")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#48484A"))
            }
        }
    }
}
