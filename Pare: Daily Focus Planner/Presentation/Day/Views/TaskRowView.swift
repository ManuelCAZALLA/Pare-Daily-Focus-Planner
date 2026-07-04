// TaskRowView.swift
import SwiftUI
import SwiftData

struct TaskRowView: View {
    let task: PareTask
    var style: TaskCard.Style = .standard
    var showsOverdueBadge: Bool = false
    let onComplete: () -> Void
    let onReschedule: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsOverdueBadge {
                Label("From yesterday", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            TaskCard(task: task, style: style)
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

#Preview {
    TaskRowPreviewContainer()
}

private struct TaskRowPreviewContainer: View {
    private let container = PareModelContainer.preview

    var body: some View {
        let task = sampleTask(in: container.mainContext)
        List {
            TaskRowView(
                task: task,
                onComplete: {},
                onReschedule: {}
            )

            TaskRowView(
                task: task,
                showsOverdueBadge: true,
                onComplete: {},
                onReschedule: {}
            )
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.pareBackground)
        .modelContainer(container)
    }

    private func sampleTask(in context: ModelContext) -> PareTask {
        let task = PareTask(title: "Deep work session", scheduledDate: Date(), priority: .high)
        task.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())
        context.insert(task)
        return task
    }
}
