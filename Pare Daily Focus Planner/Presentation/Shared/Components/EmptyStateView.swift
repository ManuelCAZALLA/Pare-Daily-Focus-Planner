// EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    var actionTitle: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.pareGreen.opacity(0.85))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle, let action {
                PareButton(title: actionTitle, style: .secondary, isFullWidth: false, action: action)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 28)
        .padding(.vertical, 32)
        .accessibilityElement(children: .combine)
    }
}

extension EmptyStateView {
    static func noTasksToday(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            systemImage: "checkmark.circle",
            title: "Nada planeado",
            message: "Añade una tarea para enfocarte en lo que importa hoy.",
            actionTitle: "Añadir tarea",
            action: action
        )
    }

    static func noObligations(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            systemImage: "doc.text",
            title: "Sin trámites registrados",
            message: "Añade el primer trámite que quieras no olvidar.",
            actionTitle: "Añadir trámite",
            action: action
        )
    }
}

#Preview("With action") {
    EmptyStateView.noTasksToday {}
        .background(Color.pareBackground)
}

#Preview("Obligations") {
    EmptyStateView.noObligations {}
        .background(Color.pareBackground)
}
