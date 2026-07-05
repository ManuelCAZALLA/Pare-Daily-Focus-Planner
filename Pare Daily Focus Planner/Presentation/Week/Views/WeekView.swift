// WeekView.swift

import SwiftUI
import SwiftData

struct WeekView: View {

    @Environment(WeekViewModel.self) private var weekVM
    @Environment(DayViewModel.self) private var dayVM

    @State private var taskToEdit: PareTask? = nil
    @State private var showReview: Bool = false
    @State private var showAddTask: Bool = false
    @State private var selectedDayForAdd: Date = Date()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 14)

                Divider().background(Color(hex: "#2A2A2C"))

                // ── Week grid
                weekGrid

                // ── Review CTA — domingo o fin de semana
                if showReviewCTA {
                    reviewCTA
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
            }

            // ── FAB
            fabButton
                .padding(.trailing, 20)
                .padding(.bottom, 32)
        }
        .sheet(item: $taskToEdit) { task in
            AddTaskSheet(editingTask: task)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
        .sheet(isPresented: $showReview) {
            WeekReviewSheet()
        }
        .onAppear {
            weekVM.loadWeek(containing: Date())
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(weekVM.isCurrentWeek ? "This Week" : "Week")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .textCase(.uppercase)
                    .kerning(0.6)

                Text(weekVM.weekRangeLabel)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)
            }

            Spacer()

            HStack(spacing: 8) {
                // Completion badge
                if weekVM.totalTasksThisWeek > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.pareGreen)
                        Text("\(Int(weekVM.weekCompletionRate * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.pareGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.pareGreen.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.pareGreen.opacity(0.25), lineWidth: 0.8)
                            )
                    )
                }

                // Week navigation
                HStack(spacing: 2) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            weekVM.loadPreviousWeek()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#1A1A1C"))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                                    )
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            weekVM.loadNextWeek()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#1A1A1C"))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Week grid

    private var weekGrid: some View {
        GeometryReader { geo in
            let colWidth = (geo.size.width - 32) / 7

            HStack(spacing: 4) {
                ForEach(weekVM.weekDates, id: \.self) { day in
                    let isToday    = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(
                        day, inSameDayAs: weekVM.selectedDate
                    )

                    WeekDayColumn(
                        date: day,
                        tasks: weekVM.tasks(for: day),
                        isToday: isToday,
                        isSelected: isSelected,
                        onTap: {
                            withAnimation(.spring(duration: 0.25)) {
                                weekVM.selectedDate = day
                            }
                        },
                        onTaskTap: { task in
                            taskToEdit = task
                        },
                        onTaskComplete: { task in
                            withAnimation(.spring(duration: 0.3)) {
                                weekVM.complete(task)
                            }
                        }
                    )
                    .frame(width: colWidth)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .padding(.bottom, showReviewCTA ? 60 : 80)
    }

    // MARK: - Review CTA

    private var reviewCTA: some View {
        Button {
            showReview = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.pareGreen.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.pareGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Review this week")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Text("Plan what moves to next week")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "#48484A"))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pareGreen.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.pareGreen.opacity(0.2), lineWidth: 0.8)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            selectedDayForAdd = weekVM.selectedDate
            showAddTask = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.pareGreen)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.pareGreen.opacity(0.5), radius: 16, x: 0, y: 6)
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(WeekSpringButtonStyle())
    }

    // MARK: - Helpers

    private var showReviewCTA: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekVM.isCurrentWeek && (weekday == 6 || weekday == 7 || weekday == 1)
    }
}

// MARK: - SpringButtonStyle

private struct WeekSpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let ctx       = container.mainContext

    // Insertar tareas en varios días de la semana
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())

    for offset in 0..<5 {
        guard let day = cal.date(byAdding: .day, value: offset - 2, to: today) else { continue }
        let t = PareTask(
            title: ["Revisar PR", "Call cliente", "Factura Q3", "Daily standup", "Deploy"][offset],
            scheduledDate: day,
            priority: [Priority.must, .high, .medium, .low, .high][offset]
        )
        if offset < 3 {
            t.scheduledTime = cal.date(bySettingHour: 9 + offset * 2, minute: 0, second: 0, of: day)
        }
        if offset == 0 { t.isCompleted = true }
        ctx.insert(t)
    }

    let taskRepo = TaskRepository(context: ctx)
    let weekRepo = WeekPlanRepository(context: ctx)

    let weekVM = WeekViewModel(weekPlanRepository: weekRepo, taskRepository: taskRepo)
    let dayVM  = DayViewModel(taskRepository: taskRepo, notificationService: NotificationService())
    weekVM.loadWeek(containing: Date())
    dayVM.loadDay(for: Date())

    return WeekView()
        .environment(weekVM)
        .environment(dayVM)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
