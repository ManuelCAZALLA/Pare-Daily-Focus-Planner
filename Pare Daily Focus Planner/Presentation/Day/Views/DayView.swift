// DayView.swift

import SwiftUI
import SwiftData

struct DayView: View {

    // MARK: - Environment
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - State
    @State private var showAddTask = false
    @State private var taskToEdit: PareTask? = nil
    @State private var showRescheduleFor: PareTask? = nil
    @State private var rescheduleDate = Date()
    @State private var selectedDate = Date()

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.pareBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Header fijo
                headerView

                // ── Week strip fijo
                weekStrip

                Divider()
                    .background(Color.pareSeparator)

                // ── Timeline scrolleable
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: []) {

                        // Banner overdue
                        if !dayVM.overdueFromYesterday.isEmpty {
                            overdueBanner
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                        }

                        // Timeline
                        timelineContent
                            .padding(.bottom, 100)
                    }
                }
            }

            // ── FAB
            fabButton
                .padding(.trailing, 20)
                .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
        .sheet(item: $taskToEdit) { task in
            AddTaskSheet(editingTask: task)
        }
        .sheet(item: $showRescheduleFor) { task in
            ReschedulePicker(task: task, selectedDate: $rescheduleDate) { date in
                dayVM.reschedule(task, to: date)
            }
        }
        .onAppear {
            dayVM.loadDay(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, new in
            dayVM.loadDay(for: new)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                // Fecha grande
                let dayMonth = AttributedString(selectedDate.formatted(.dateTime.day().month(.wide)), attributes: AttributeContainer().font(.system(size: 28, weight: .heavy)).foregroundColor(Color.pareTextPrimary))
                let space = AttributedString(" ")
                let year = AttributedString(selectedDate.formatted(.dateTime.year()), attributes: AttributeContainer().font(.system(size: 28, weight: .heavy)).foregroundColor(Color.pareGreen))
                Text(dayMonth + space + year)

                // Saludo / día de la semana
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(Color.pareTextSecondary)
            }

            Spacer()

            // Progress pill
            let done  = dayVM.tasksToday.filter(\.isCompleted).count
            let total = dayVM.tasksToday.count
            if total > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(done)/\(total)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(done == total ? Color.pareGreen : Color.pareTextPrimary)

                    Text("tasks")
                        .font(.caption)
                        .foregroundStyle(Color.pareTextSecondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        let days = currentWeekDays()

        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                let isToday    = Calendar.current.isDateInToday(day)

                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedDate = day
                    }
                } label: {
                    VStack(spacing: 5) {
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(
                                isSelected ? Color.pareGreen : Color.pareTextTertiary
                            )

                        ZStack {
                            Circle()
                                .fill(
                                    isSelected
                                    ? Color.pareGreen
                                    : (isToday ? Color.pareGreen.opacity(0.15) : Color.clear)
                                )
                                .frame(width: 32, height: 32)

                            Text(day.formatted(.dateTime.day()))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    isSelected
                                    ? .white
                                    : (isToday ? Color.pareGreen : Color.pareTextSecondary)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .background(Color.pareBackground)
    }

    // MARK: - Timeline content

    private var timelineContent: some View {
        let timedTasks   = dayVM.tasksToday.filter { $0.scheduledTime != nil }
            .sorted { ($0.scheduledTime ?? Date()) < ($1.scheduledTime ?? Date()) }
        let untimedTasks = dayVM.tasksToday.filter { $0.scheduledTime == nil }

        return VStack(spacing: 0) {
            // Tareas con hora — timeline
            if !timedTasks.isEmpty {
                HStack(alignment: .top, spacing: 0) {

                    // Columna de horas + línea
                    VStack(spacing: 0) {
                        ForEach(timedTasks) { task in
                            TimelineHourLabel(task: task)
                        }
                    }
                    .frame(width: 52)

                    // Línea vertical
                    Rectangle()
                        .fill(Color.pareTimelineLine)
                        .frame(width: 1)
                        .overlay(alignment: .top) {
                            // Punto "ahora"
                            if Calendar.current.isDateInToday(selectedDate) {
                                Circle()
                                    .fill(Color.pareGreen)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -3.5)
                                    .offset(y: nowLineOffset(tasks: timedTasks))
                            }
                        }

                    // Cards
                    VStack(spacing: 10) {
                        ForEach(timedTasks) { task in
                            taskRow(task)
                                .padding(.leading, 12)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.trailing, 16)
                }
                .padding(.top, 14)
            }

            // Sin hora — sección al final
            if !untimedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("No time set")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pareTextTertiary)
                        .textCase(.uppercase)
                        .kerning(0.5)
                        .padding(.horizontal, 20)
                        .padding(.top, timedTasks.isEmpty ? 20 : 28)

                    ForEach(untimedTasks) { task in
                        taskRow(task)
                            .padding(.horizontal, 16)
                    }
                }
            }

            // Empty state
            if dayVM.tasksToday.isEmpty {
                emptyState
            }
        }
    }

    // MARK: - Task row

    @ViewBuilder
    private func taskRow(_ task: PareTask) -> some View {
        TaskRowView(
            task: task,
            isOverdue: dayVM.overdueFromYesterday.contains(where: { $0.id == task.id }),
            onComplete: {
                withAnimation(.spring(duration: 0.3)) {
                    dayVM.complete(task)
                }
            },
            onReschedule: {
                rescheduleDate = Date()
                showRescheduleFor = task
            },
            onTap: {
                taskToEdit = task
            }
        )
    }

    // MARK: - Overdue banner

    private var overdueBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundStyle(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 1) {
                Text("From yesterday")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.pareTextPrimary)
                Text("\(dayVM.overdueFromYesterday.count) task\(dayVM.overdueFromYesterday.count > 1 ? "s" : "") rescheduled")
                    .font(.caption)
                    .foregroundStyle(Color.pareTextSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.orange.opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.pareGreen.opacity(0.25))

            Text("No tasks")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.pareTextSecondary)

            Text("Tap + to add your first task for today")
                .font(.subheadline)
                .foregroundStyle(Color.pareTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            showAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(Color.pareGreen)
                .clipShape(Circle())
                .shadow(color: Color.pareGreen.opacity(0.45), radius: 16, x: 0, y: 8)
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:  return "Good morning"
        case 12..<18: return "Good afternoon"
        default:       return "Good evening"
        }
    }

    private func currentWeekDays() -> [Date] {
        let cal   = Calendar(identifier: .iso8601)
        let start = cal.date(from: cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: selectedDate
        )) ?? selectedDate
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func nowLineOffset(tasks: [PareTask]) -> CGFloat {
        // Aproximación visual: altura por tarea ~74pt
        let cardHeight: CGFloat = 74
        let now = Date()
        guard let first = tasks.first?.scheduledTime else { return 0 }
        let elapsed = now.timeIntervalSince(first)
        let total   = tasks.last?.scheduledTime.flatMap { $0.timeIntervalSince(first) } ?? 1
        guard total > 0 else { return 0 }
        let ratio   = min(max(elapsed / total, 0), 1)
        return ratio * (CGFloat(tasks.count) * cardHeight)
    }
}

// MARK: - TimelineHourLabel

private struct TimelineHourLabel: View {
    let task: PareTask

    var body: some View {
        VStack {
            if let time = task.scheduledTime {
                Text(time.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.pareTextTertiary)
                    .frame(height: 74, alignment: .top)
                    .padding(.top, 14)
            }
        }
    }
}

// MARK: - ReschedulePicker

private struct ReschedulePicker: View {
    let task: PareTask
    @Binding var selectedDate: Date
    let onConfirm: (Date) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pareBackground.ignoresSafeArea()

                DatePicker(
                    "New date",
                    selection: $selectedDate,
                    in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.pareGreen)
                .colorScheme(.dark)
                .padding()
            }
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.pareBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.pareTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") {
                        onConfirm(selectedDate)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.pareGreen)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let context   = container.mainContext

    let t1 = PareTask(title: "Enviar factura de mayo", scheduledDate: Date(), priority: .must)
    t1.scheduledTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
    let t2 = PareTask(title: "Revisar propuesta Q3", scheduledDate: Date(), priority: .high)
    t2.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())
    let t3 = PareTask(title: "Responder emails pendientes", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Leer 20 páginas", scheduledDate: Date(), priority: .low)
    [t1, t2, t3, t4].forEach { context.insert($0) }

    let vm = DayViewModel(
        taskRepository: TaskRepository(context: context),
        notificationService: NotificationService()
    )
    vm.loadDay(for: Date())

    return DayView()
        .environment(vm)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
