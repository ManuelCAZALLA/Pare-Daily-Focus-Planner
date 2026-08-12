// RoutineWidgetView.swift
import SwiftUI
import WidgetKit

struct RoutineWidgetView: View {
    let entry: PareWidgetEntry

    var body: some View {
        VStack(spacing: 10) {
            PareWidgetHeader(title: String(localized: "widget.routine.short"))

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                indicator(emoji: "🌅", done: entry.morningDone)
                indicator(emoji: "🌙", done: entry.eveningDone)
            }

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 11))
                Text(String(format: String(localized: "widget.streak"), entry.streak))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .overlay(glow)
        .widgetURL(URL(string: "pare://routine"))
    }

    private func indicator(emoji: String, done: Bool) -> some View {
        ZStack {
            Circle()
                .fill(done ? Color.pareGreen.opacity(0.16) : Color.white.opacity(0.05))
            Circle()
                .stroke(done ? Color.pareGreen.opacity(0.55) : Color.white.opacity(0.1), lineWidth: 1)
            Text(emoji)
                .font(.system(size: 22))
                .saturation(done ? 1 : 0)
                .opacity(done ? 1 : 0.4)
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.pareGreenDark)
                    .padding(3)
                    .background(Circle().fill(Color.pareGreen))
                    .offset(x: 14, y: 14)
            }
        }
        .frame(width: 56, height: 56)
    }

    /// Glow sutil de fondo
    private var glow: some View {
        RadialGradient(
            colors: [Color.pareGreen.opacity(0.16), .clear],
            center: .topTrailing,
            startRadius: 0,
            endRadius: 110
        )
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    RoutineWidget()
} timeline: {
    PareWidgetEntry.placeholder
}
