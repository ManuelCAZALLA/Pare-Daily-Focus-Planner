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
    
    // Navegación entre semanas
    @State private var weekOffset: Int   = 0

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Fondo oscuro profundo y elegante
            LinearGradient(
                colors: [Color(hex: "#121316"), Color(hex: "#080809")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                
                weekStrip
                    .frame(height: 75)
                    .padding(.bottom, 12)
                
                Divider()
                    .background(Color.white.opacity(0.06))

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        if !dayVM.overdueFromYesterday.isEmpty {
                            overdueBanner
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                        }
                        timelineContent
                            .padding(.bottom, 110)
                    }
                }
            }

            fabButton
                .padding(.trailing, 24)
                .padding(.bottom, 36)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet(initialScheduledDate: selectedDate)
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

    // MARK: - Header (Rediseñado y Limpio)

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "#636366"))
                    .textCase(.uppercase)
                    .kerning(1.6)

                Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(selectedDate.formatted(.dateTime.year()))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.pareGreen)
                    .opacity(0.9)
            }

            Spacer()

            // Progress badge (Solo si hay tareas)
            let total = dayVM.tasksToday.count
            let done  = dayVM.tasksToday.filter(\.isCompleted).count

            if total > 0 {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 3.5)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: Double(done) / Double(total))
                        .stroke(
                            LinearGradient(
                                colors: [Color.pareGreen.opacity(0.7), Color.pareGreen],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: done)

                    VStack(spacing: -1) {
                        Text("\(done)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(done == total ? Color.pareGreen : .white)
                        Text("/\(total)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color(hex: "#636366"))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        TabView(selection: $weekOffset) {
            ForEach(-50...50, id: \.self) { offset in
                weekView(for: offset)
                    .tag(offset)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private func weekView(for offset: Int) -> some View {
        let days = weekDays(for: offset)
        return HStack(spacing: 8) {
            ForEach(days, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                let isToday    = Calendar.current.isDateInToday(day)
                let hasTask    = !dayVM.tasksToday.isEmpty && Calendar.current.isDate(day, inSameDayAs: selectedDate)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedDate = day
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(
                                isSelected ? (isToday ? Color.pareGreen : .white) :
                                isToday ? Color.pareGreen.opacity(0.7) :
                                Color(hex: "#48484A")
                            )

                        ZStack {
                            Circle()
                                .fill(
                                    isSelected
                                    ? (isToday ? Color.pareGreen : .white)
                                    : (isToday ? Color.pareGreen.opacity(0.1) : Color.clear)
                                )
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                                        .opacity(isSelected || isToday ? 0 : 1)
                                )

                            Text(day.formatted(.dateTime.day()))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    isSelected ? .black :
                                    isToday ? Color.pareGreen :
                                    .white
                                )
                        }
                        
                        Circle()
                            .fill(isSelected ? Color.pareGreen : Color.pareGreen.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .opacity(hasTask ? 1 : 0)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
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
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }

            if !untimedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("SIN HORA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#48484A"))
                            .kerning(1.4)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, timedTasks.isEmpty ? 24 : 32)

                    VStack(spacing: 12) {
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
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [Color(hex: "#FF453A"), Color(hex: "#FF9F0A")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 38, height: 38)
                
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("De ayer")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(dayVM.overdueFromYesterday.count) pendientes necesitan atención")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: "#48484A"))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#161618"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)
                )
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .blur(radius: 16)
                    .opacity(0.3)
                
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .opacity(0.6)
            }
            .padding(.bottom, 4)

            VStack(spacing: 6) {
                Text("Todo despejado")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text("Es un buen momento para descansar\no planificar tu día.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button { showAddTask = true } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pareGreen.opacity(0.9), Color.pareGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.pareGreen.opacity(0.25), radius: 12, x: 0, y: 6)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(SpringButtonStyle())
    }

    // MARK: - Helpers

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 0..<12:  return String(localized: "Buenos días")
        case 12..<18: return String(localized: "Buenas tardes")
        default:       return String(localized: "Buenas noches")
        }
    }

    private func weekDays(for offset: Int) -> [Date] {
        let cal = Calendar.current
        let startOfCurrentWeek = cal.date(from: cal.dateComponents(
            [.yearForWeekOfYear, .weekOfYear], from: Date()
        )) ?? Date()
        
        let startOfTargetWeek = cal.date(byAdding: .weekOfYear, value: offset, to: startOfCurrentWeek) ?? startOfCurrentWeek
        
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfTargetWeek) }
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

struct TimelineRow: View {
    let task: PareTask
    let isLast: Bool
    let isNow: Bool
    let onComplete: () -> Void
    let onReschedule: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                Text(task.scheduledTime?.formatted(.dateTime.hour().minute()) ?? "")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isNow ? Color.pareGreen : Color(hex: "#48484A"))
                    .frame(width: 44, alignment: .trailing)
                    .padding(.top, 14)

                if !isLast {
                    Rectangle()
                        .fill(Color(hex: "#222224"))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 44)

            ZStack {
                Circle()
                    .fill(isNow ? Color.pareGreen : Color(hex: "#222224"))
                    .frame(width: 8, height: 8)
                if isNow {
                    Circle()
                        .fill(Color.pareGreen.opacity(0.2))
                        .frame(width: 16, height: 16)
                }
            }
            .frame(width: 20)
            .padding(.top, 16)

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

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - ReschedulePicker

struct ReschedulePicker: View {
    let task: PareTask
    @Binding var selectedDate: Date
    let onConfirm: (Date) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#080809").ignoresSafeArea()
                DatePicker("", selection: $selectedDate,
                           in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.pareGreen)
                    .colorScheme(.dark)
                    .padding()
            }
            .navigationTitle("Reagendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#080809"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Mover") { onConfirm(selectedDate); dismiss() }
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
