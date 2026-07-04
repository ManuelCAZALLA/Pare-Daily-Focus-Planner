// DayView.swift
import SwiftUI
import SwiftData

struct DayView: View {

    // MARK: - Environment
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - State
    @State private var showAddTask       = false
    @State private var taskToEdit: PareTask?     = nil
    @State private var showRescheduleFor: PareTask? = nil
    @State private var rescheduleDate    = Date()
    @State private var selectedDate      = Date()

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                weekStrip
                    .padding(.bottom, 4)
                Divider()
                    .background(Color(hex: "#2A2A2C"))

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        if !dayVM.overdueFromYesterday.isEmpty {
                            overdueBanner
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                        timelineContent
                            .padding(.bottom, 110)
                    }
                }
            }

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
        .onAppear { dayVM.loadDay(for: selectedDate) }
        .onChange(of: selectedDate) { _, new in dayVM.loadDay(for: new) }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                // Saludo
                Text(greeting)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .textCase(.uppercase)
                    .kerning(0.8)

                // Fecha grande
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)

                    Text(selectedDate.formatted(.dateTime.year()))
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(Color.pareGreen)
                }
            }

            Spacer()

            // Progress badge
            let done  = dayVM.tasksToday.filter(\.isCompleted).count
            let total = dayVM.tasksToday.count

            VStack(alignment: .trailing, spacing: 2) {
                if total > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#2A2A2C"), lineWidth: 3)
                            .frame(width: 52, height: 52)

                        Circle()
                            .trim(from: 0, to: total > 0 ? Double(done) / Double(total) : 0)
                            .stroke(Color.pareGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 52, height: 52)
                            .animation(.spring(duration: 0.5), value: done)

                        VStack(spacing: 0) {
                            Text("\(done)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(done == total && total > 0 ? Color.pareGreen : .white)
                            Text("/\(total)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(hex: "#8E8E93"))
                        }
                    }
                } else {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#2A2A2C"), lineWidth: 3)
                            .frame(width: 52, height: 52)
                        Text("0")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: "#48484A"))
                    }
                }

                if dayVM.streak > 0 {
                    HStack(spacing: 3) {
                        Text("🔥")
                            .font(.system(size: 11))
                        Text("\(dayVM.streak)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: "#FF9500"))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        let days = currentWeekDays()
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(days, id: \.self) { day in
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    let isToday    = Calendar.current.isDateInToday(day)
                    let hasTask    = !dayVM.tasksToday.isEmpty && Calendar.current.isDate(day, inSameDayAs: selectedDate)

                    Button {
                        withAnimation(.spring(duration: 0.25)) { selectedDate = day }
                    } label: {
                        VStack(spacing: 6) {
                            Text(day.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(
                                    isSelected ? Color.pareGreen :
                                    isToday ? Color(hex: "#8E8E93") :
                                    Color(hex: "#48484A")
                                )

                            ZStack {
                                // Fondo seleccionado
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        isSelected
                                        ? Color.pareGreen
                                        : isToday
                                            ? Color.pareGreen.opacity(0.12)
                                            : Color(hex: "#1A1A1C")
                                    )
                                    .frame(width: 36, height: 42)

                                VStack(spacing: 2) {
                                    Text(day.formatted(.dateTime.day()))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(
                                            isSelected ? .white :
                                            isToday ? Color.pareGreen :
                                            Color(hex: "#8E8E93")
                                        )
                                    // Dot si tiene tareas
                                    Circle()
                                        .fill(isSelected ? .white.opacity(0.6) : Color.pareGreen)
                                        .frame(width: 4, height: 4)
                                        .opacity(hasTask ? 1 : 0)
                                }
                            }
                        }
                        .frame(minWidth: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Timeline content

    private var timelineContent: some View {
        let timedTasks   = dayVM.tasksToday
            .filter { $0.scheduledTime != nil }
            .sorted { ($0.scheduledTime ?? Date()) < ($1.scheduledTime ?? Date()) }
        let untimedTasks = dayVM.tasksToday.filter { $0.scheduledTime == nil }

        return VStack(spacing: 0) {

            if !timedTasks.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(timedTasks.enumerated()), id: \.element.id) { index, task in
                        TimelineRow(
                            task: task,
                            isLast: index == timedTasks.count - 1,
                            isNow: isCurrentTask(task, in: timedTasks),
                            onComplete: {
                                withAnimation(.spring(duration: 0.3)) { dayVM.complete(task) }
                            },
                            onReschedule: {
                                rescheduleDate = Date()
                                showRescheduleFor = task
                            },
                            onTap: { taskToEdit = task }
                        )
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
            }

            if !untimedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Rectangle()
                            .fill(Color(hex: "#2A2A2C"))
                            .frame(height: 0.5)
                        Text("No time set")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "#48484A"))
                            .kerning(0.8)
                            .textCase(.uppercase)
                            .fixedSize()
                        Rectangle()
                            .fill(Color(hex: "#2A2A2C"))
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, timedTasks.isEmpty ? 24 : 28)

                    VStack(spacing: 8) {
                        ForEach(untimedTasks) { task in
                            TaskRowView(
                                task: task,
                                isOverdue: dayVM.overdueFromYesterday.contains(where: { $0.id == task.id }),
                                onComplete: {
                                    withAnimation(.spring(duration: 0.3)) { dayVM.complete(task) }
                                },
                                onReschedule: {
                                    rescheduleDate = Date()
                                    showRescheduleFor = task
                                },
                                onTap: { taskToEdit = task }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            if dayVM.tasksToday.isEmpty { emptyState }
        }
    }

    // MARK: - Overdue banner

    private var overdueBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("From yesterday")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("\(dayVM.overdueFromYesterday.count) task\(dayVM.overdueFromYesterday.count > 1 ? "s" : "") moved")
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
                .fill(Color.orange.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.orange.opacity(0.18), lineWidth: 0.8)
                )
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.pareGreen.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.pareGreen.opacity(0.4))
            }

            VStack(spacing: 6) {
                Text("All clear")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                Text("Tap + to plan your day")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#48484A"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button { showAddTask = true } label: {
            ZStack {
                Circle()
                    .fill(Color.pareGreen)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.pareGreen.opacity(0.5), radius: 18, x: 0, y: 8)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - Helpers

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
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

    private func isCurrentTask(_ task: PareTask, in tasks: [PareTask]) -> Bool {
        guard Calendar.current.isDateInToday(selectedDate),
              let time = task.scheduledTime else { return false }
        let now = Date()
        return time <= now && (tasks.last?.id == task.id || {
            if let idx = tasks.firstIndex(where: { $0.id == task.id }),
               idx + 1 < tasks.count,
               let next = tasks[idx + 1].scheduledTime {
                return next > now
            }
            return false
        }())
    }
}

// MARK: - TimelineRow

private struct TimelineRow: View {
    let task: PareTask
    let isLast: Bool
    let isNow: Bool
    let onComplete: () -> Void
    let onReschedule: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Columna hora + línea
            VStack(spacing: 0) {
                Text(task.scheduledTime?.formatted(.dateTime.hour().minute()) ?? "")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isNow ? Color.pareGreen : Color(hex: "#48484A"))
                    .frame(width: 44, alignment: .trailing)
                    .padding(.top, 14)

                if !isLast {
                    Rectangle()
                        .fill(Color(hex: "#2A2A2C"))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 44)

            // Dot en la línea
            ZStack {
                Circle()
                    .fill(isNow ? Color.pareGreen : Color(hex: "#2A2A2C"))
                    .frame(width: 8, height: 8)
                if isNow {
                    Circle()
                        .fill(Color.pareGreen.opacity(0.3))
                        .frame(width: 16, height: 16)
                }
            }
            .frame(width: 20)
            .padding(.top, 16)

            // Card
            TaskRowView(
                task: task,
                onComplete: onComplete,
                onReschedule: onReschedule,
                onTap: onTap
            )
            .padding(.leading, 10)
            .padding(.bottom, isLast ? 0 : 12)
        }
    }
}

// MARK: - SpringButtonStyle

private struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
                Color(hex: "#0C0C0E").ignoresSafeArea()
                DatePicker("", selection: $selectedDate,
                           in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.pareGreen)
                    .colorScheme(.dark)
                    .padding()
            }
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") { onConfirm(selectedDate); dismiss() }
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
    let ctx = container.mainContext

    let t1 = PareTask(title: "Enviar factura de mayo", scheduledDate: Date(), priority: .must)
    t1.scheduledTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
    let t2 = PareTask(title: "Revisar propuesta Q3", scheduledDate: Date(), priority: .high)
    t2.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())
    let t3 = PareTask(title: "Responder emails", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Leer 20 páginas", scheduledDate: Date(), priority: .low)
    [t1, t2, t3, t4].forEach { ctx.insert($0) }

    let vm = DayViewModel(
        taskRepository: TaskRepository(context: ctx),
        notificationService: NotificationService()
    )
    vm.loadDay(for: Date())

    return DayView()
        .environment(vm)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
