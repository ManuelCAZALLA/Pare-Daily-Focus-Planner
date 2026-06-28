// TaskRowView.swift
import SwiftUI
import SwiftData

struct TaskRowView: View {
    let task: PareTask
    var style: TaskCard.Style = .standard
    var isOverdue: Bool = false
    let onComplete: () -> Void
    let onReschedule: () -> Void
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isOverdue {
                Label("From yesterday", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.leading, 4)
            }

            TaskCard(task: task, style: style)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap?()
                }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onReschedule()
            } label: {
                Label("Reschedule", systemImage: "calendar")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onComplete()
            } label: {
                Label("Complete", systemImage: "checkmark")
            }
            .tint(Color.pareGreen)
        }
    }
}

// MARK: - Preview

#Preview {
    TaskRowPreviewContainer()
}

private struct TaskRowPreviewContainer: View {
    private let container = PareModelContainer.preview

    var body: some View {
        let task = sampleTask(in: container.mainContext)
        return ZStack {
            Color.pareBackground.ignoresSafeArea()
            VStack(spacing: 10) {
                TaskRowView(
                    task: task,
                    onComplete: {},
                    onReschedule: {}
                )
                TaskRowView(
                    task: task,
                    isOverdue: true,
                    onComplete: {},
                    onReschedule: {}
                )
            }
            .padding()
        }
        .modelContainer(container)
        .preferredColorScheme(.dark)
    }

    private func sampleTask(in context: ModelContext) -> PareTask {
        let task = PareTask(title: "Deep work session", scheduledDate: Date(), priority: .high)
        task.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())
        context.insert(task)
        return task
    }
}
