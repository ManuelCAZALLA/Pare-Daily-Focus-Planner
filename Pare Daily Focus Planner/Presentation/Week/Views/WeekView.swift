// WeekView.swift
// Presentation/Week/Views/WeekView.swift
import SwiftUI

struct WeekView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.pareGreen.opacity(0.4))
                Text("Week view")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#48484A"))
            }
        }
    }
}
