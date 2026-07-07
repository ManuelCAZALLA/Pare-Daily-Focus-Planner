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
            // Fondo moderno con ligero degradado
            LinearGradient(
                colors: [Color(hex: "#1A1B20"), Color(hex: "#0C0C0E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                
                weekStrip
                    .frame(height: 75)
                    .padding(.bottom, 8)
                
                Divider()
                    .background(Color.white.opacity(0.1))

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
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                // Saludo y Streak integrados
                HStack(spacing: 8) {
                    Text(greeting)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#8E8E93"))
                        .textCase(.uppercase)
                        .kerning(1.2)
                    
                    if dayVM.streak > 0 {
                        HStack(spacing: 4) {
                            Text("🔥")
                                .font(.system(size: 10))
                            Text("\(dayVM.streak)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15), in: Capsule())
                    }
                }

                // Fecha grande
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)

                    Text(selectedDate.formatted(.dateTime.year()))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(Color.pareGreen)
                }
            }

            Spacer()

            // Progress badge (Solo se muestra si hay tareas)
            let total = dayVM.tasksToday.count
            let done  = dayVM.tasksToday.filter(\.isCompleted).count

            if total > 0 {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 54, height: 54)

                    Circle()
                        .trim(from: 0, to: Double(done) / Double(total))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.pareGreen.opacity(0.6), Color.pareGreen]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: done)

                    VStack(spacing: -2) {
                        Text("\(done)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(done == total ? Color.pareGreen : .white)
                        Text("/\(total)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Week strip (Navegable)

    private var weekStrip: some View {
        // TabView permite hacer swipe infinito entre semanas
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
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedDate = day
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(
                                isSelected ? (isToday ? Color.pareGreen : .white) :
                                isToday ? Color.pareGreen.opacity(0.8) :
                                Color(hex: "#636366")
                            )

                        ZStack {
                            Circle()
                                .fill(
                                    isSelected
                                    ? (isToday ? Color.pareGreen : .white)
                                    : (isToday ? Color.pareGreen.opacity(0.15) : Color.clear)
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                                        .opacity(isSelected || isToday ? 0 : 1)
                                )

                            VStack(spacing: 2) {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(
                                        isSelected ? .black :
                                        isToday ? Color.pareGreen :
                                        Color.white
                                    )
                            }
                        }
                        
                        // Dot si tiene tareas
                        Circle()
                            .fill(isSelected ? Color.pareGreen : Color.pareGreen.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .opacity(hasTask ? 1 : 0)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
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
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("SIN HORA")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: "#636366"))
                            .kerning(1.2)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
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
                        LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("De ayer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(dayVM.overdueFromYesterday.count) tareas requieren tu atención")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "#636366"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1A1A1C"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.pareGreen.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .strokeBorder(Color.pareGreen.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(Color.pareGreen)
            }
            .padding(.bottom, 8)

            VStack(spacing: 8) {
                Text("Todo despejado")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Es un buen momento para descansar\no planificar tu día.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 90)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button { showAddTask = true } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pareGreen.opacity(0.8), Color.pareGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.pareGreen.opacity(0.4), radius: 15, x: 0, y: 8)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
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

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
                Color(hex: "#0C0C0E").ignoresSafeArea()
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
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
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
