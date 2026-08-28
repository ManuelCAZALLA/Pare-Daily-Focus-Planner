// RoutineWidgetView.swift
import SwiftUI
import WidgetKit

struct RoutineWidgetView: View {
    let entry: TramiteWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular: accessoryCircular
        case .accessoryRectangular: accessoryRectangular
        case .systemMedium: medium
        default: small
        }
    }

    // MARK: - Small

    private var small: some View {
        VStack(spacing: 10) {
            TramiteWidgetHeader(title: String(localized: "widget.routine.short"))

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
        .widgetURL(URL(string: "recuerdatustramites://routine"))
    }

    // MARK: - Medium

    private var medium: some View {
        VStack(spacing: 10) {
            TramiteWidgetHeader(title: String(localized: "widget.routine.short"))

            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    indicator(emoji: "🌅", done: entry.morningDone)
                    Text(String(localized: "widget.routine.morning"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                VStack(spacing: 6) {
                    indicator(emoji: "🌙", done: entry.eveningDone)
                    Text(String(localized: "widget.routine.evening"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 12))
                Text(String(format: String(localized: "widget.streak"), entry.streak))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .overlay(glow)
        .widgetURL(URL(string: "recuerdatustramites://routine"))
    }

    // MARK: - Lock Screen Accessories

    private var accessoryCircular: some View {
        ZStack {
            Circle()
                .fill(Color.tramiteGreen.opacity(0.16))
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text("🌅").font(.system(size: 10))
                    Text("🌙").font(.system(size: 10))
                }
                Text("\(entry.streak)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    private var accessoryRectangular: some View {
        HStack(spacing: 8) {
            Text(entry.morningDone ? "🌅" : "🌅")
                .font(.system(size: 14))
                .opacity(entry.morningDone ? 1 : 0.4)
            Text(entry.eveningDone ? "🌙" : "🌙")
                .font(.system(size: 14))
                .opacity(entry.eveningDone ? 1 : 0.4)
            Spacer()
            HStack(spacing: 2) {
                Text("🔥")
                    .font(.system(size: 10))
                Text("\(entry.streak)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    private func indicator(emoji: String, done: Bool) -> some View {
        ZStack {
            Circle()
                .fill(done ? Color.tramiteGreen.opacity(0.16) : Color.white.opacity(0.05))
            Circle()
                .stroke(done ? Color.tramiteGreen.opacity(0.55) : Color.white.opacity(0.1), lineWidth: 1)
            Text(emoji)
                .font(.system(size: 22))
                .saturation(done ? 1 : 0)
                .opacity(done ? 1 : 0.4)
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color.tramiteGreenDark)
                    .padding(3)
                    .background(Circle().fill(Color.tramiteGreen))
                    .offset(x: 14, y: 14)
            }
        }
        .frame(width: 56, height: 56)
    }

    private var glow: some View {
        RadialGradient(
            colors: [Color.tramiteGreen.opacity(0.16), .clear],
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
    TramiteWidgetEntry.placeholder
}
