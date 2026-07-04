// StatsView.swift
// Presentation/Stats/Views/StatsView.swift
import SwiftUI

struct StatsView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.pareGreen.opacity(0.4))
                Text("Stats")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#48484A"))
            }
        }
    }
}
