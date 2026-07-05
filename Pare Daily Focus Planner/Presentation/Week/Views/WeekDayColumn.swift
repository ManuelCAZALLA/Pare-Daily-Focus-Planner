// WeekDayColumn.swift

import SwiftUI

struct WeekDayColumn: View {

    let date: Date
    let tasks: [PareTask]
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onTaskTap: (PareTask) -> Void
    let onTaskComplete: (PareTask) -> Void

    private var cal: Calendar { Calendar.current }

    var body: some View {
        VStack(spacing: 0) {

            // ── Day header
            Button(action: onTap) {
                VStack(spacing: 5) {
                    Text(date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(
                            isSelected ? Color.pareGreen :
                            isToday    ? Color.pareGreen.opacity(0.7) :
                                         Color(hex: "#48484A")
                        )
                        .kerning(0.5)

                    ZStack {
                        Circle()
                            .fill(
                                isSelected ? Color.pareGreen :
                                isToday    ? Color.pareGreen.opacity(0.15) :
                                             Color.clear
                            )
                            .frame(width: 30, height: 30)

                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(
                                isSelected ? .white :
                                isToday    ? Color.pareGreen :
                                             Color(hex: "#8E8E93")
                            )
                    }

                    // Completion bar
                    completionBar
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Divider()
                .background(Color(hex: "#2A2A2C"))

            // ── Tasks list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 6) {
                    if tasks.isEmpty {
                        emptyColumn
                    } else {
                        ForEach(tasks) { task in
                            WeekTaskChip(
                                task: task,
                                onTap: { onTaskTap(task) },
                                onComplete: { onTaskComplete(task) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isSelected
                    ? Color.pareGreen.opacity(0.04)
                    : Color(hex: "#111113")
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isSelected
                            ? Color.pareGreen.opacity(0.2)
                            : Color(hex: "#1E1E20"),
                            lineWidth: 0.8
                        )
                )
        )
    }

    // MARK: - Completion bar

    private var completionBar: some View {
        let total     = tasks.count
        let completed = tasks.filter(\.isCompleted).count
        let ratio     = total > 0 ? Double(completed) / Double(total) : 0

        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(hex: "#2A2A2C"))
                .frame(height: 2)

            GeometryReader { geo in
                Capsule()
                    .fill(
                        ratio == 1
                        ? Color.pareGreen
                        : Color.pareGreen.opacity(0.6)
                    )
                    .frame(width: geo.size.width * ratio, height: 2)
                    .animation(.spring(duration: 0.4), value: completed)
            }
            .frame(height: 2)
        }
        .frame(height: 2)
        .padding(.horizontal, 6)
        .opacity(total > 0 ? 1 : 0)
    }

    // MARK: - Empty column

    private var emptyColumn: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "#2A2A2C"))
                .padding(.top, 12)
            Text("Empty")
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: "#38383A"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - WeekTaskChip

struct WeekTaskChip: View {
    let task: PareTask
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    // Dot prioridad
                    Circle()
                        .fill(Color.priority(task.priority))
                        .frame(width: 5, height: 5)

                    // Hora si tiene
                    if let time = task.scheduledTime {
                        Text(time.formatted(.dateTime.hour().minute()))
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(Color.pareGreen.opacity(0.8))
                    }

                    Spacer(minLength: 0)

                    // Check pequeño
                    Button(action: onComplete) {
                        Image(systemName: task.isCompleted
                              ? "checkmark.circle.fill"
                              : "circle")
                            .font(.system(size: 12))
                            .foregroundStyle(
                                task.isCompleted
                                ? Color.pareGreen
                                : Color(hex: "#3A3A3C")
                            )
                    }
                    .buttonStyle(.plain)
                }

                Text(task.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(
                        task.isCompleted
                        ? Color(hex: "#48484A")
                        : .white
                    )
                    .strikethrough(task.isCompleted, color: Color(hex: "#48484A"))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#1C1C1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.priority(task.priority).opacity(0.08),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                Color.priority(task.priority).opacity(
                                    task.isCompleted ? 0.08 : 0.2
                                ),
                                lineWidth: 0.6
                            )
                    )
            )
            .opacity(task.isCompleted ? 0.55 : 1)
        }
        .buttonStyle(.plain)
    }
}
