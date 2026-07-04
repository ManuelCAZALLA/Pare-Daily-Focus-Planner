// EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
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
            title: "Nothing planned",
            message: "Add a task to focus on what matters today.",
            actionTitle: "Add Task",
            action: action
        )
    }

    static func noWeekTasks() -> EmptyStateView {
        EmptyStateView(
            systemImage: "calendar",
            title: "Week is open",
            message: "Plan your week on Sunday, or drag tasks across days."
        )
    }

    static func noStats() -> EmptyStateView {
        EmptyStateView(
            systemImage: "chart.bar",
            title: "No data yet",
            message: "Complete a few tasks to see your progress."
        )
    }
}

#Preview("With action") {
    EmptyStateView.noTasksToday {}
        .background(Color.pareBackground)
}

#Preview("Message only") {
    EmptyStateView.noWeekTasks()
        .background(Color.pareBackground)
}
