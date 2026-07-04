// TaskCard.swift
import SwiftUI
import SwiftData

struct TaskCard: View {
    enum Style {
        case standard
        case compact
    }

    let task: PareTask
    var style: Style = .standard

    var body: some View {
        HStack(spacing: 12) {
            priorityBar

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(style == .compact ? .subheadline.weight(.medium) : .body.weight(.medium))
                    .fontDesign(.rounded)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(style == .compact ? 2 : 3)

                if style == .standard, let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                metadataRow
            }

            Spacer(minLength: 0)

            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(style == .compact ? .subheadline : .body)
                    .foregroundStyle(Color.pareGreen)
            }
        }
        .padding(style == .compact ? 10 : 14)
        .background(Color.pareCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(task.isCompleted ? 0.72 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var priorityBar: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color.priority(task.priority))
            .frame(width: 4)
            .frame(maxHeight: .infinity)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var metadataRow: some View {
        if task.scheduledTime != nil || style == .standard || task.recurrenceRaw != nil {
            HStack(spacing: 8) {
                if let time = task.scheduledTime {
                    Label {
                        Text(time, format: .dateTime.hour().minute())
                    } icon: {
                        Image(systemName: "clock")
                    }
                }

                if style == .standard {
                    Text(priorityLabel(task.priority))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.priority(task.priority).opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.priority(task.priority))
                }

                if task.recurrenceRaw != nil {
                    Image(systemName: "repeat")
                        .accessibilityLabel("Recurring task")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var accessibilityLabel: String {
        var parts = [task.title]
        if task.isCompleted { parts.append("completed") }
        parts.append(priorityLabel(task.priority))
        if let time = task.scheduledTime {
            parts.append(time.formatted(date: .omitted, time: .shortened))
        }
        return parts.joined(separator: ", ")
    }

    private func priorityLabel(_ priority: Priority) -> String {
        switch priority {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        case .must:   return "Must"
        }
    }
}

#Preview {
    TaskCardPreviewContainer()
}

private struct TaskCardPreviewContainer: View {
    private let container = PareModelContainer.preview

    var body: some View {
        let task = sampleTask(in: container.mainContext)
        ScrollView {
            VStack(spacing: 12) {
                TaskCard(task: task)
                TaskCard(task: task, style: .compact)
                TaskCard(task: completedTask(in: container.mainContext))
            }
            .padding()
        }
        .background(Color.pareBackground)
        .modelContainer(container)
    }

    private func sampleTask(in context: ModelContext) -> PareTask {
        let task = PareTask(title: "Plan the week ahead", scheduledDate: Date(), priority: .must)
        task.notes = "Review last week and pick 3 priorities."
        task.scheduledTime = Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())
        task.recurrenceRaw = "daily"
        context.insert(task)
        return task
    }

    private func completedTask(in context: ModelContext) -> PareTask {
        let task = PareTask(title: "Morning walk", scheduledDate: Date(), priority: .low)
        task.isCompleted = true
        task.completedAt = Date()
        context.insert(task)
        return task
    }
}
