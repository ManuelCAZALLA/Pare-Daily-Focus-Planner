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
            VStack(alignment: .leading, spacing: 3) {
                // Fecha grande
                let dayMonth = AttributedString(selectedDate.formatted(.dateTime.day().month(.wide)), attributes: AttributeContainer().font(.system(size: 28, weight: .heavy)).foregroundColor(Color.white))
                let space = AttributedString(" ")
                let year = AttributedString(selectedDate.formatted(.dateTime.year()), attributes: AttributeContainer().font(.system(size: 28, weight: .heavy)).foregroundColor(Color.pareGreen))
                Text(dayMonth + space + year)

                // Saludo / día de la semana
                Text(greeting)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#8E8E93"))
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
                        .foregroundStyle(done == total ? Color.pareGreen : Color.white)

                    Text("tasks")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(done == total ? Color.pareGreen.opacity(0.15) : Color(hex: "#1C1C1E"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    done == total ? Color.pareGreen.opacity(0.4) : Color(hex: "#38383A"),
                                    lineWidth: 0.5
                                )
                        )
                )
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
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(
                                isSelected ? Color.pareGreen : Color(hex: "#8E8E93")
                            )

                        ZStack {
                            Circle()
                                .fill(
                                    isSelected
                                    ? Color.pareGreen
                                    : (isToday ? Color.pareGreen.opacity(0.18) : Color(hex: "#2C2C2E"))
                                )
                                .frame(width: 36, height: 36)

                            // Ring exterior para hoy no-seleccionado
                            if isToday && !isSelected {
                                Circle()
                                    .strokeBorder(Color.pareGreen.opacity(0.5), lineWidth: 1.5)
                                    .frame(width: 36, height: 36)
                            }

                            Text(day.formatted(.dateTime.day()))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    isSelected
                                    ? .white
                                    : (isToday ? Color.pareGreen : Color.white)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44) // HIG minimum tap target
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
                    .frame(width: 56)

                    // Línea vertical
                    Rectangle()
                        .fill(Color(hex: "#38383A"))
                        .frame(width: 1)
                        .overlay(alignment: .top) {
                            // Punto "ahora"
                            if Calendar.current.isDateInToday(selectedDate) {
                                Circle()
                                    .fill(Color.pareGreen)
                                    .frame(width: 10, height: 10)
                                    .shadow(color: Color.pareGreen.opacity(0.6), radius: 4)
                                    .offset(x: -4.5)
                                    .offset(y: nowLineOffset(tasks: timedTasks))
                            }
                        }

                    // Cards
                    VStack(spacing: 12) {
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
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(Color(hex: "#48484A"))
                            .frame(width: 20, height: 1)
                        Text("Sin hora")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .textCase(.uppercase)
                            .kerning(0.5)
                        Rectangle()
                            .fill(Color(hex: "#48484A"))
                            .frame(height: 1)
                    }
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
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("From yesterday")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                Text("\(dayVM.overdueFromYesterday.count) task\(dayVM.overdueFromYesterday.count > 1 ? "s" : "") rescheduled")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.orange.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.pareGreen.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.pareGreen.opacity(0.7))
            }

            VStack(spacing: 6) {
                Text("Sin tareas para hoy")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                Text("Pulsa + para añadir tu primera tarea")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
        .padding(.horizontal, 32)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            showAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(
                        colors: [Color.pareGreen, Color(hex: "#16A34A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.pareGreen.opacity(0.55), radius: 20, x: 0, y: 8)
        }
        .accessibilityLabel("Añadir tarea")
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
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .frame(height: 80, alignment: .top)
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
