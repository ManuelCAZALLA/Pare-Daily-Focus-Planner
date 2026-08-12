// TodayWidgetView.swift
import SwiftUI
import WidgetKit

struct TodayWidgetView: View {
    let entry: PareWidgetEntry
    @Environment(\.widgetFamily) private var family

    private var completedCount: Int { entry.tasks.filter(\.isCompleted).count }
    private var totalCount: Int { entry.tasks.count }

    private var pendingTasks: [WidgetTask] {
        entry.tasks
            .filter { !$0.isCompleted }
            .sorted { lhs, rhs in
                if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
                switch (lhs.scheduledTime, rhs.scheduledTime) {
                case let (l?, r?): return l < r
                case (_?, nil):    return true
                case (nil, _?):    return false
                case (nil, nil):   return lhs.title < rhs.title
                }
            }
            .prefix(3)
            .map { $0 }
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        switch family {
        case .systemSmall: small
        default: medium
        }
    }

    // MARK: - Small

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            PareWidgetHeader(title: String(localized: "widget.today.label"))
            Spacer(minLength: 0)

            if totalCount == 0 {
                emptyState
            } else {
                HStack(spacing: 14) {
                    progressRing
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(pendingTasks.count)")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text(String(localized: "widget.pending.short"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)

            Text("\(completedCount)/\(totalCount)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .widgetURL(URL(string: "pare://today"))
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.pareGreen, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(completedCount)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 58, height: 58)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🎯")
                .font(.system(size: 26))
            Text(String(localized: "widget.noTasks"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Medium

    private var medium: some View {
        VStack(alignment: .leading, spacing: 10) {
            PareWidgetHeader(title: String(localized: "widget.today.label"))

            if totalCount == 0 {
                emptyStateMedium
            } else if pendingTasks.isEmpty {
                VStack(spacing: 6) {
                    Text("🎯")
                        .font(.system(size: 30))
                    Text(String(localized: "widget.noTasks"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    ForEach(pendingTasks) { task in
                        taskRow(task)
                    }
                }
            }

            Spacer(minLength: 0)

            ProgressView(value: progress)
                .tint(Color.pareGreen)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)
        }
        .widgetURL(URL(string: "pare://today"))
    }

    private var emptyStateMedium: some View {
        VStack(spacing: 6) {
            Text("🎯")
                .font(.system(size: 30))
            Text(String(localized: "widget.noTasks"))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "widget.addTasksHint"))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func taskRow(_ task: WidgetTask) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.priority(task.priority))
                .frame(width: 3, height: 16)

            Text(task.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 6)

            if let time = task.scheduledTime {
                Label(WidgetFormatters.time.string(from: time), systemImage: "clock")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .labelStyle(.titleAndIcon)
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    TodayWidget()
} timeline: {
    PareWidgetEntry.placeholder
}
