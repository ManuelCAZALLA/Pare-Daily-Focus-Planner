// WeekReviewSheet.swift

import SwiftUI

struct WeekReviewSheet: View {

    @Environment(WeekViewModel.self) private var weekVM
    @Environment(DayViewModel.self) private var dayVM
    @Environment(\.dismiss) private var dismiss

    // Tareas de la semana seleccionadas para mover a la siguiente
    @State private var selectedForNextWeek: Set<UUID> = []
    @State private var currentStep: Step = .review

    enum Step { case review, plan }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0C0C0E").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step indicator
                    stepIndicator
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    // Content
                    switch currentStep {
                    case .review: reviewStep
                    case .plan:   planStep
                    }
                }
            }
            .navigationTitle(currentStep == .review ? "Week Review" : "Plan Next Week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(currentStep == .review ? "Next →" : "Done") {
                        if currentStep == .review {
                            withAnimation(.spring(duration: 0.35)) {
                                currentStep = .plan
                            }
                        } else {
                            applyNextWeekPlan()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.pareGreen)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .preferredColorScheme(.dark)
    }

    // MARK: - Step indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach([Step.review, Step.plan], id: \.hashValue) { step in
                Capsule()
                    .fill(
                        step == currentStep
                        ? Color.pareGreen
                        : Color(hex: "#2A2A2C")
                    )
                    .frame(height: 3)
                    .animation(.spring(duration: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Review step

    private var reviewStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Stats card
                weekStatsCard

                // Completed tasks
                let completed = allWeekTasks.filter(\.isCompleted)
                if !completed.isEmpty {
                    taskSection(
                        title: "Completed",
                        icon: "checkmark.circle.fill",
                        iconColor: Color.pareGreen,
                        tasks: completed,
                        selectable: false
                    )
                }

                // Pending tasks — seleccionables para mover a siguiente semana
                let pending = allWeekTasks.filter { !$0.isCompleted }
                if !pending.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "clock.badge.exclamationmark")
                                .foregroundStyle(Color(hex: "#FF9500"))
                            Text("Pending")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("Select to move to next week")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(hex: "#8E8E93"))
                        }
                        .padding(.horizontal, 2)

                        VStack(spacing: 6) {
                            ForEach(pending) { task in
                                ReviewTaskRow(
                                    task: task,
                                    isSelected: selectedForNextWeek.contains(task.id)
                                ) {
                                    if selectedForNextWeek.contains(task.id) {
                                        selectedForNextWeek.remove(task.id)
                                    } else {
                                        selectedForNextWeek.insert(task.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Plan step

    private var planStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Summary de lo seleccionado
                if !selectedForNextWeek.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader(
                            icon: "arrow.right.circle.fill",
                            color: Color(hex: "#007AFF"),
                            title: "Moving to next week",
                            subtitle: "\(selectedForNextWeek.count) task\(selectedForNextWeek.count > 1 ? "s" : "")"
                        )

                        VStack(spacing: 6) {
                            ForEach(tasksSelectedForNext) { task in
                                CompactTaskRow(task: task)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Mensaje motivacional
                motivationalCard

                Spacer(minLength: 60)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Week stats card

    private var weekStatsCard: some View {
        HStack(spacing: 0) {
            StatBlock(
                value: "\(weekVM.completedTasksThisWeek)",
                label: "Done",
                color: Color.pareGreen
            )

            Divider()
                .background(Color(hex: "#2A2A2C"))
                .padding(.vertical, 12)

            StatBlock(
                value: "\(allWeekTasks.filter { !$0.isCompleted }.count)",
                label: "Pending",
                color: Color(hex: "#FF9500")
            )

            Divider()
                .background(Color(hex: "#2A2A2C"))
                .padding(.vertical, 12)

            StatBlock(
                value: "\(Int(weekVM.weekCompletionRate * 100))%",
                label: "Rate",
                color: weekVM.weekCompletionRate > 0.7
                    ? Color.pareGreen
                    : Color(hex: "#FF9500")
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1A1A1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                )
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Task section

    private func taskSection(
        title: String,
        icon: String,
        iconColor: Color,
        tasks: [PareTask],
        selectable: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: icon, color: iconColor, title: title, subtitle: "\(tasks.count)")

            VStack(spacing: 6) {
                ForEach(tasks) { task in
                    CompactTaskRow(task: task)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Motivational card

    private var motivationalCard: some View {
        let rate = weekVM.weekCompletionRate
        let message: String
        let emoji: String

        switch rate {
        case 0.8...:
            emoji = "🔥"
            message = "Excellent week! You crushed it. Keep the momentum going."
        case 0.5..<0.8:
            emoji = "💪"
            message = "Good progress. A few things slipped — no worries, they're on next week."
        default:
            emoji = "🌱"
            message = "Every week is a fresh start. Plan lighter and focus on what truly matters."
        }

        return VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "#8E8E93"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1A1A1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                )
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private var allWeekTasks: [PareTask] {
        weekVM.weekDates.flatMap { weekVM.tasks(for: $0) }
    }

    private var tasksSelectedForNext: [PareTask] {
        allWeekTasks.filter { selectedForNextWeek.contains($0.id) }
    }

    private func applyNextWeekPlan() {
        let cal = Calendar.current
        guard let nextMonday = cal.date(
            byAdding: .weekOfYear, value: 1,
            to: weekVM.weekDates.first ?? Date()
        ) else { return }

        for task in tasksSelectedForNext {
            weekVM.moveTask(task, to: nextMonday)
        }
        weekVM.loadNextWeek()
    }

    private func sectionHeader(
        icon: String,
        color: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 14))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "#8E8E93"))
        }
        .padding(.horizontal, 2)
    }
}

// MARK: - ReviewTaskRow

private struct ReviewTaskRow: View {
    let task: PareTask
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                // Selection indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected
                              ? Color(hex: "#007AFF").opacity(0.15)
                              : Color(hex: "#2A2A2C"))
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#007AFF"))
                    }
                }

                // Priority dot
                Circle()
                    .fill(Color.priority(task.priority))
                    .frame(width: 6, height: 6)

                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                if let time = task.scheduledTime {
                    Text(time.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? Color(hex: "#007AFF").opacity(0.06)
                          : Color(hex: "#1A1A1C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected
                                ? Color(hex: "#007AFF").opacity(0.3)
                                : Color(hex: "#2A2A2C"),
                                lineWidth: 0.8
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CompactTaskRow

private struct CompactTaskRow: View {
    let task: PareTask

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.priority(task.priority))
                .frame(width: 6, height: 6)

            Text(task.title)
                .font(.subheadline)
                .foregroundStyle(
                    task.isCompleted ? Color(hex: "#48484A") : .white
                )
                .strikethrough(task.isCompleted)
                .lineLimit(1)

            Spacer()

            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.pareGreen.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#1A1A1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - StatBlock

private struct StatBlock: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "#8E8E93"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Step Hashable

extension WeekReviewSheet.Step: Hashable {}
