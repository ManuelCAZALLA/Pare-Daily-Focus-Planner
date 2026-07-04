// PareButton.swift
import SwiftUI

struct PareButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    var isFullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(PareButtonStyle(style: style, isFullWidth: isFullWidth))
    }

    @ViewBuilder
    private var label: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }
}

struct PareFAB: View {
    var systemImage: String = "plus"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.pareGreen, in: Circle())
                .shadow(color: Color.pareGreen.opacity(0.35), radius: 8, y: 4)
        }
        .accessibilityLabel("Add task")
    }
}

private struct PareButtonStyle: ButtonStyle {
    let style: PareButton.Style
    let isFullWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.pareGreen.opacity(0.4), lineWidth: 1)
                }
            }
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:      return .white
        case .secondary:  return .pareGreen
        case .destructive: return .white
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch style {
        case .primary:
            return isPressed ? .pareGreenDark : .pareGreen
        case .secondary:
            return Color.pareCard
        case .destructive:
            return isPressed ? Color.red.opacity(0.85) : .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PareButton(title: "Get Started", systemImage: "arrow.right", style: .primary) {}

        PareButton(title: "Review Week", style: .secondary) {}

        PareButton(title: "Delete Plan", style: .destructive) {}

        HStack {
            Spacer()
            PareFAB {}
        }
    }
    .padding()
    .background(Color.pareBackground)
}
