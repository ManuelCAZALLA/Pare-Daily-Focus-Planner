// AddTaskSheet.swift
import SwiftUI
import SwiftData

// MARK: - QuickTask Model
private struct QuickTask: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let defaultHour: Int
    let defaultMinute: Int
    let defaultNotes: String
    let defaultPriority: Priority
    let color: Color
}

struct AddTaskSheet: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - Form state
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var scheduledDate: Date = Date()
    @State private var hasTime: Bool = false
    @State private var scheduledTime: Date = Calendar.current.date(
        bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @State private var priority: Priority = .medium
    @State private var hasRecurrence: Bool = false
    @State private var recurrence: Recurrence = .daily

    // MARK: - Animation State
    @State private var animateGlows: Bool = false

    // MARK: - Edit mode (optional)
    var editingTask: PareTask? = nil

    // MARK: - Focus
    @FocusState private var titleFocused: Bool

    // MARK: - Predetermined Quick Tasks
    private var quickTasks: [QuickTask] {
        [
            QuickTask(
                title: "Ir al gym",
                icon: "dumbbell.fill",
                defaultHour: 18,
                defaultMinute: 0,
                defaultNotes: "Sesión de entrenamiento (1h 30m)",
                defaultPriority: .medium,
                color: Color.pareGreen
            ),
            QuickTask(
                title: "Ver serie",
                icon: "tv.fill",
                defaultHour: 21,
                defaultMinute: 30,
                defaultNotes: "Ver mi serie favorita (1h)",
                defaultPriority: .low,
                color: Color(hex: "#A855F7")
            ),
            QuickTask(
                title: "Responder email",
                icon: "envelope.fill",
                defaultHour: 9,
                defaultMinute: 0,
                defaultNotes: "Revisar bandeja de entrada",
                defaultPriority: .medium,
                color: Color(hex: "#3B82F6")
            ),
            QuickTask(
                title: "Cita médica",
                icon: "cross.case.fill",
                defaultHour: 11,
                defaultMinute: 0,
                defaultNotes: "Consulta médica de control",
                defaultPriority: .must,
                color: Color(hex: "#EF4444")
            ),
            QuickTask(
                title: "Pasar ITV",
                icon: "car.fill",
                defaultHour: 10,
                defaultMinute: 0,
                defaultNotes: "Pasar la inspección técnica del coche",
                defaultPriority: .high,
                color: Color(hex: "#F59E0B")
            ),
            QuickTask(
                title: "Hacer compra",
                icon: "cart.fill",
                defaultHour: 17,
                defaultMinute: 30,
                defaultNotes: "Supermercado (comida semanal)",
                defaultPriority: .low,
                color: Color(hex: "#10B981")
            ),
            QuickTask(
                title: "Llamada trabajo",
                icon: "phone.fill",
                defaultHour: 15,
                defaultMinute: 0,
                defaultNotes: "Reunión rápida de seguimiento",
                defaultPriority: .high,
                color: Color(hex: "#06B6D4")
            )
        ]
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Liquid Glass dynamic gradient
                liquidGlassBackdrop

                ScrollView {
                    VStack(spacing: 16) {
                        
                        // ── Predetermined tasks (only when creating new task)
                        if editingTask == nil {
                            quickAddSection
                        }

                        // ── Title field
                        titleSection

                        // ── Priority picker
                        prioritySection

                        // ── Date strip horizontal
                        dateSection

                        // ── Time toggle + compact picker
                        timeSection

                        // ── Recurrence
                        recurrenceSection

                        // ── Notes
                        notesSection

                        // ── Delete button (edit mode only)
                        if editingTask != nil {
                            deleteSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(editingTask == nil ? "Nueva Tarea" : "Editar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingTask == nil ? "Añadir" : "Guardar") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(title.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.white.opacity(0.3)
                        : Color.pareGreen)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            titleFocused = true
            if let task = editingTask { populate(from: task) }
            
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateGlows = true
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }

    // MARK: - Liquid Glass Backdrop
    private var liquidGlassBackdrop: some View {
        ZStack {
            Color.pareBackground
                .ignoresSafeArea()

            GeometryReader { geo in
                ZStack {
                    // Circle 1: Pare Green
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color.pareGreen.opacity(0.22), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        ))
                        .frame(width: 400, height: 400)
                        .position(
                            x: animateGlows ? geo.size.width * 0.15 : geo.size.width * 0.4,
                            y: animateGlows ? geo.size.height * 0.35 : geo.size.height * 0.15
                        )

                    // Circle 2: Blue Glow
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: "#007AFF").opacity(0.22), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 220
                        ))
                        .frame(width: 440, height: 440)
                        .position(
                            x: animateGlows ? geo.size.width * 0.85 : geo.size.width * 0.6,
                            y: animateGlows ? geo.size.height * 0.45 : geo.size.height * 0.65
                        )

                    // Circle 3: Purple Glow
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: "#A855F7").opacity(0.18), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        ))
                        .frame(width: 360, height: 360)
                        .position(
                            x: animateGlows ? geo.size.width * 0.25 : geo.size.width * 0.5,
                            y: animateGlows ? geo.size.height * 0.8 : geo.size.height * 0.7
                        )
                }
            }
            .blur(radius: 70)
            .ignoresSafeArea()

            Color.black.opacity(0.1)
                .ignoresSafeArea()
        }
    }

    // MARK: - Quick Add Section (Sugerencias)
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SUGERENCIAS RÁPIDAS")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickTasks) { qTask in
                        Button {
                            selectQuickTask(qTask)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: qTask.icon)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(qTask.color.opacity(0.2))
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(qTask.color.opacity(0.4), lineWidth: 1)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(qTask.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)

                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 9))
                                        Text(String(format: "%02d:%02d", qTask.defaultHour, qTask.defaultMinute))
                                            .font(.system(size: 9))
                                        Text("•")
                                        Text(qTask.defaultPriority.label)
                                            .font(.system(size: 9))
                                    }
                                    .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.04))
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.12), .white.opacity(0.02)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.horizontal, 4)
    }

    private func selectQuickTask(_ qTask: QuickTask) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            title = qTask.title
            notes = qTask.defaultNotes
            priority = qTask.defaultPriority
            hasTime = true
            scheduledTime = Calendar.current.date(
                bySettingHour: qTask.defaultHour,
                minute: qTask.defaultMinute,
                second: 0,
                of: scheduledDate
            ) ?? Date()
        }
    }

    // MARK: - Title section
    private var titleSection: some View {
        CardSection {
            TextField("¿Qué necesitas hacer?", text: $title, axis: .vertical)
                .font(.body)
                .fontWeight(.semibold)
                .focused($titleFocused)
                .submitLabel(.done)
                .lineLimit(1...3)
                .foregroundStyle(.white)
        }
    }

    // MARK: - Priority section
    private var prioritySection: some View {
        CardSection(header: "Prioridad") {
            HStack(spacing: 8) {
                ForEach(Priority.allCases, id: \.rawValue) { p in
                    PriorityChip(priority: p, isSelected: priority == p) {
                        withAnimation(.spring(duration: 0.2)) { priority = p }
                    }
                }
            }
        }
    }

    // MARK: - Date section — strip horizontal de días
    private var dateSection: some View {
        CardSection(header: "Fecha") {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(nextDays(60), id: \.self) { day in
                            DayChip(
                                date: day,
                                isSelected: Calendar.current.isDate(day, inSameDayAs: scheduledDate)
                            ) {
                                withAnimation(.spring(duration: 0.25)) {
                                    scheduledDate = day
                                }
                            }
                            .id(day)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
                .onAppear {
                    proxy.scrollTo(
                        Calendar.current.startOfDay(for: scheduledDate),
                        anchor: .leading
                    )
                }
            }
        }
    }

    // MARK: - Time section — compact picker
    private var timeSection: some View {
        CardSection(header: "Hora") {
            Toggle(isOn: $hasTime.animation()) {
                Label("Establecer hora", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .tint(Color.pareGreen)

            if hasTime {
                DatePicker(
                    "",
                    selection: $scheduledTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(Color.pareGreen)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Recurrence section
    private var recurrenceSection: some View {
        CardSection(header: "Repetir") {
            Toggle(isOn: $hasRecurrence.animation()) {
                Label("Tarea recurrente", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .tint(Color.pareGreen)

            if hasRecurrence {
                VStack(spacing: 0) {
                    ForEach(recurrenceOptions, id: \.label) { option in
                        Button {
                            withAnimation { recurrence = option }
                        } label: {
                            HStack {
                                Text(option.label)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Spacer()
                                if recurrence == option {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.pareGreen)
                                        .fontWeight(.semibold)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if option.label != recurrenceOptions.last?.label {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Notes section
    private var notesSection: some View {
        CardSection(header: "Notas") {
            TextField("Añade una nota...", text: $notes, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(3...6)
        }
    }

    // MARK: - Delete section
    private var deleteSection: some View {
        Button(role: .destructive) {
            if let task = editingTask {
                dayVM.deleteTask(task)
                dismiss()
            }
        } label: {
            HStack {
                Spacer()
                Label("Eliminar Tarea", systemImage: "trash")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.15))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
            .foregroundStyle(.red)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Helpers
    private func nextDays(_ count: Int) -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<count).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
    }

    private var recurrenceOptions: [Recurrence] {
        [
            .daily,
            .weekly(days: [1, 2, 3, 4, 5]),
            .weekly(days: [1, 2, 3, 4, 5, 6, 7]),
            .monthly(day: Calendar.current.component(.day, from: scheduledDate)),
            .custom(intervalDays: 2),
            .custom(intervalDays: 7)
        ]
    }

    // MARK: - Actions
    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let task = editingTask {
            task.title         = trimmed
            task.notes         = notes.isEmpty ? nil : notes
            task.scheduledDate = scheduledDate
            task.scheduledTime = hasTime ? mergedDateTime() : nil
            task.priority      = priority
            task.recurrenceRaw = hasRecurrence ? encodeRecurrence(recurrence) : nil
            dayVM.reschedule(task, to: scheduledDate)
        } else {
            let task = PareTask(
                title: trimmed,
                scheduledDate: scheduledDate,
                priority: priority
            )
            task.notes         = notes.isEmpty ? nil : notes
            task.scheduledTime = hasTime ? mergedDateTime() : nil
            task.recurrenceRaw = hasRecurrence ? encodeRecurrence(recurrence) : nil
            dayVM.addTask(task)
        }
        dismiss()
    }

    private func mergedDateTime() -> Date {
        let cal = Calendar.current
        let timeComps = cal.dateComponents([.hour, .minute], from: scheduledTime)
        return cal.date(
            bySettingHour: timeComps.hour   ?? 9,
            minute:        timeComps.minute ?? 0,
            second:        0,
            of:            scheduledDate
        ) ?? scheduledDate
    }

    private func populate(from task: PareTask) {
        title         = task.title
        notes         = task.notes ?? ""
        scheduledDate = task.scheduledDate
        priority      = task.priority
        if let time = task.scheduledTime {
            hasTime       = true
            scheduledTime = time
        }
        if let raw = task.recurrenceRaw,
           let rec = decodeRecurrence(raw) {
            hasRecurrence = true
            recurrence    = rec
        }
    }

    private func encodeRecurrence(_ r: Recurrence) -> String? {
        try? String(data: JSONEncoder().encode(r), encoding: .utf8)
    }

    private func decodeRecurrence(_ raw: String) -> Recurrence? {
        guard let data = raw.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Recurrence.self, from: data)
    }
}

// MARK: - ScaleButtonStyle
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - DayChip
private struct DayChip: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var cal: Calendar { Calendar.current }
    private var isToday: Bool { cal.isDateInToday(date) }
    private var isTomorrow: Bool { cal.isDateInTomorrow(date) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.narrow)))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : .white.opacity(0.5))

                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.85))

                Group {
                    if isToday {
                        Text("Today")
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                    } else if isTomorrow {
                        Text("Tmrw")
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                    } else {
                        Text(date.formatted(.dateTime.month(.abbreviated)))
                            .foregroundStyle(isSelected ? .white.opacity(0.7) : .white.opacity(0.4))
                    }
                }
                .font(.system(size: 8, weight: .semibold))
            }
            .frame(width: 44, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.pareGreen.opacity(0.8) : Color.white.opacity(0.04))
            )
            .background {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.pareGreen.opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.pareGreen.opacity(0.2) : .clear,
                radius: 4, x: 0, y: 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - CardSection
private struct CardSection<Content: View>: View {
    var header: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let header {
                Text(header.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
            }
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, header == nil ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - PriorityChip
private struct PriorityChip: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: priority.iconName)
                    .font(.caption)
                Text(priority.label)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? Color.priority(priority).opacity(0.2) : Color.white.opacity(0.04))
            )
            .background {
                if !isSelected {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
            .foregroundStyle(
                isSelected ? Color.priority(priority) : .white.opacity(0.6)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.priority(priority).opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Previews
#Preview("Add Task") {
    AddTaskSheet()
        .environment(DayViewModel(
            taskRepository: TaskRepository(context: PareModelContainer.preview.mainContext),
            notificationService: NotificationService()
        ))
        .modelContainer(PareModelContainer.preview)
}

#Preview("Edit Task") {
    let context = PareModelContainer.preview.mainContext
    let task = PareTask(title: "Revisar propuesta Q3", scheduledDate: Date(), priority: .high)
    task.scheduledTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())
    context.insert(task)
    return AddTaskSheet(editingTask: task)
        .environment(DayViewModel(
            taskRepository: TaskRepository(context: context),
            notificationService: NotificationService()
        ))
        .modelContainer(PareModelContainer.preview)
}
