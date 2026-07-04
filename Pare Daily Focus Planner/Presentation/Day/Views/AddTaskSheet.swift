// AddTaskSheet.swift
// Presentation/Day/Views/AddTaskSheet.swift
import SwiftUI
import SwiftData
import UserNotifications

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
    @State private var showRecurrenceOptions: Bool = false

    // MARK: - Edit mode
    var editingTask: PareTask? = nil

    // MARK: - Focus
    @FocusState private var titleFocused: Bool
    
    // MARK: - Notifications
    @State private var showNotificationAlert: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // ── Quick suggestions (solo modo crear)
                    if editingTask == nil {
                        quickSuggestions
                    }

                    // ── Title
                    titleField

                    // ── Priority
                    prioritySelector

                    // ── Date
                    dateStrip

                    // ── Time
                    timeRow

                    // ── Recurrence
                    recurrenceRow

                    // ── Notes
                    notesField

                    // ── Delete (edit mode)
                    if editingTask != nil {
                        deleteButton
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "#0C0C0E"))
            .navigationTitle(editingTask == nil ? "Nueva Tarea" : "Editar Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingTask == nil ? "Añadir" : "Guardar") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            title.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color(hex: "#48484A")
                            : Color.pareGreen
                        )
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            // ── Alerta de Notificaciones
            .alert("Activar notificaciones", isPresented: $showNotificationAlert) {
                Button("Ahora no", role: .cancel) { }
                Button("Permitir") {
                    Task {
                        // Llamamos a tu servicio a través del ViewModel
                        await dayVM.notificationService.requestPermission()
                    }
                }
            } message: {
                Text("¿Quieres recibir un aviso en tu dispositivo cuando llegue la hora de esta tarea?")
            }
        }
        .onAppear {
            titleFocused = true
            if let task = editingTask { populate(from: task) }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .preferredColorScheme(.dark)
    }

    // MARK: - Quick suggestions

    private var quickSuggestions: some View {
        let suggestions = dayVM.suggestions.prefix(4)
        guard !suggestions.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Sugerencias rápidas")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(suggestions)) { task in
                            Button {
                                title = task.title
                                priority = task.priority
                                titleFocused = false
                            } label: {
                                HStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.priority(task.priority).opacity(0.15))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: task.priority.iconName)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.priority(task.priority))
                                    }

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(task.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                        if let time = task.scheduledTime {
                                            HStack(spacing: 3) {
                                                Image(systemName: "clock")
                                                    .font(.system(size: 9))
                                                Text(time.formatted(.dateTime.hour().minute()))
                                                    .font(.system(size: 10))
                                            }
                                            .foregroundStyle(Color(hex: "#8E8E93"))
                                        } else {
                                            Text(task.priority.label)
                                                .font(.system(size: 10))
                                                .foregroundStyle(Color.priority(task.priority).opacity(0.8))
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "#1A1A1C"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.5)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        )
    }

    // MARK: - Title field

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("¿Qué necesitas hacer?", text: $title, axis: .vertical)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .tint(Color.pareGreen)
                .focused($titleFocused)
                .lineLimit(1...3)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#1A1A1C"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    title.isEmpty
                                    ? Color(hex: "#2A2A2C")
                                    : Color.pareGreen.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }

    // MARK: - Priority selector

    private var prioritySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Prioridad")

            HStack(spacing: 8) {
                ForEach(Priority.allCases, id: \.rawValue) { p in
                    Button {
                        withAnimation(.spring(duration: 0.2)) { priority = p }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: p.iconName)
                                .font(.system(size: 13, weight: .semibold))
                            Text(p.label)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    priority == p
                                    ? Color.priority(p).opacity(0.18)
                                    : Color(hex: "#1A1A1C")
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            priority == p
                                            ? Color.priority(p).opacity(0.5)
                                            : Color(hex: "#2A2A2C"),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .foregroundStyle(
                            priority == p
                            ? Color.priority(p)
                            : Color(hex: "#8E8E93")
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Date strip

    private var dateStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Fecha")

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(nextDays(60), id: \.self) { day in
                            let isSelected = Calendar.current.isDate(day, inSameDayAs: scheduledDate)
                            let isToday    = Calendar.current.isDateInToday(day)
                            let isTomorrow = Calendar.current.isDateInTomorrow(day)

                            Button {
                                withAnimation(.spring(duration: 0.25)) { scheduledDate = day }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(day.formatted(.dateTime.weekday(.narrow)))
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(
                                            isSelected ? .white.opacity(0.85) :
                                            isToday ? Color.pareGreen :
                                            Color(hex: "#48484A")
                                        )

                                    Text(day.formatted(.dateTime.day()))
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(
                                            isSelected ? .white :
                                            isToday ? Color.pareGreen :
                                            Color(hex: "#8E8E93")
                                        )

                                    Group {
                                        if isToday {
                                            Text("Hoy")
                                                .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                                        } else if isTomorrow {
                                            Text("Mañana")
                                                .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                                        } else {
                                            Text(day.formatted(.dateTime.month(.abbreviated)))
                                                .foregroundStyle(isSelected ? .white.opacity(0.7) : Color(hex: "#48484A"))
                                        }
                                    }
                                    .font(.system(size: 9, weight: .semibold))
                                }
                                .frame(width: 46, height: 68)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            isSelected
                                            ? Color.pareGreen
                                            : isToday
                                                ? Color.pareGreen.opacity(0.08)
                                                : Color(hex: "#1A1A1C")
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(
                                                    isSelected ? Color.clear :
                                                    isToday ? Color.pareGreen.opacity(0.3) :
                                                    Color(hex: "#2A2A2C"),
                                                    lineWidth: 0.8
                                                )
                                        )
                                        .shadow(
                                            color: isSelected ? Color.pareGreen.opacity(0.35) : .clear,
                                            radius: 8, x: 0, y: 4
                                        )
                                )
                            }
                            .buttonStyle(.plain)
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

    // MARK: - Time row

    private var timeRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Hora")

            VStack(spacing: 0) {
                Button {
                    withAnimation(.spring(duration: 0.3)) { hasTime.toggle() }
                    
                    // Comprobar permisos si se activa la hora
                    if hasTime {
                        checkNotificationStatus()
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(hasTime ? Color.pareGreen.opacity(0.15) : Color(hex: "#2A2A2C"))
                                .frame(width: 34, height: 34)
                            Image(systemName: hasTime ? "clock.fill" : "clock")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(hasTime ? Color.pareGreen : Color(hex: "#8E8E93"))
                        }

                        Text(hasTime
                             ? scheduledTime.formatted(.dateTime.hour().minute())
                             : "Sin hora")
                            .font(.subheadline)
                            .fontWeight(hasTime ? .semibold : .regular)
                            .foregroundStyle(hasTime ? .white : Color(hex: "#8E8E93"))

                        Spacer()

                        Image(systemName: hasTime ? "xmark.circle.fill" : "chevron.right")
                            .foregroundStyle(Color(hex: "#48484A"))
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                if hasTime {
                    Divider()
                        .background(Color(hex: "#2A2A2C"))
                        .padding(.horizontal, 14)

                    DatePicker("", selection: $scheduledTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color.pareGreen)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#1A1A1C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                    )
            )
        }
    }

    // MARK: - Recurrence row

    private var recurrenceRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Repetir")

            VStack(spacing: 0) {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        hasRecurrence.toggle()
                        showRecurrenceOptions = hasRecurrence
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(hasRecurrence ? Color(hex: "#007AFF").opacity(0.15) : Color(hex: "#2A2A2C"))
                                .frame(width: 34, height: 34)
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(hasRecurrence ? Color(hex: "#007AFF") : Color(hex: "#8E8E93"))
                        }

                        Text(hasRecurrence ? recurrence.label : "No se repite")
                            .font(.subheadline)
                            .fontWeight(hasRecurrence ? .semibold : .regular)
                            .foregroundStyle(hasRecurrence ? .white : Color(hex: "#8E8E93"))

                        Spacer()

                        Image(systemName: showRecurrenceOptions ? "chevron.up" : "chevron.down")
                            .foregroundStyle(Color(hex: "#48484A"))
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                if showRecurrenceOptions {
                    Divider()
                        .background(Color(hex: "#2A2A2C"))
                        .padding(.horizontal, 14)

                    VStack(spacing: 0) {
                        ForEach(recurrenceOptions, id: \.label) { option in
                            Button {
                                withAnimation { recurrence = option; hasRecurrence = true }
                            } label: {
                                HStack {
                                    Text(option.label)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if recurrence == option && hasRecurrence {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.pareGreen)
                                            .fontWeight(.semibold)
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            if option.label != recurrenceOptions.last?.label {
                                Divider()
                                    .background(Color(hex: "#2A2A2C"))
                                    .padding(.horizontal, 14)
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#1A1A1C"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                    )
            )
        }
    }

    // MARK: - Notes field

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Notas")

            TextField("Añade una nota...", text: $notes, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(.white)
                .tint(Color.pareGreen)
                .lineLimit(3...6)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#1A1A1C"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 0.8)
                        )
                )
        }
    }

    // MARK: - Delete button

    private var deleteButton: some View {
        Button(role: .destructive) {
            if let task = editingTask {
                dayVM.deleteTask(task)
                dismiss()
            }
        } label: {
            HStack {
                Spacer()
                Label("Eliminar tarea", systemImage: "trash")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.red.opacity(0.2), lineWidth: 0.8)
                    )
            )
            .foregroundStyle(.red)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section label

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color(hex: "#48484A"))
            .kerning(0.8)
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
    
    // Función para revisar el estado sin pedir permisos obligatorios de inmediato
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    showNotificationAlert = true
                }
            }
        }
    }

    // MARK: - Save

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
            let task = PareTask(title: trimmed, scheduledDate: scheduledDate, priority: priority)
            task.notes         = notes.isEmpty ? nil : notes
            task.scheduledTime = hasTime ? mergedDateTime() : nil
            task.recurrenceRaw = hasRecurrence ? encodeRecurrence(recurrence) : nil
            dayVM.addTask(task)
        }
        dismiss()
    }

    private func mergedDateTime() -> Date {
        let cal   = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: scheduledTime)
        return cal.date(
            bySettingHour: comps.hour ?? 9,
            minute:        comps.minute ?? 0,
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
            hasTime = true
            scheduledTime = time
        }
        if let raw = task.recurrenceRaw, let rec = decodeRecurrence(raw) {
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

// MARK: - Preview

#Preview("Nueva Tarea") {
    let context = PareModelContainer.preview.mainContext
    let vm = DayViewModel(
        taskRepository: TaskRepository(context: context),
        notificationService: NotificationService() // Utilizando tu servicio
    )

    let s1 = PareTask(title: "Ir al gym", scheduledDate: Date(), priority: .medium)
    s1.scheduledTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())
    let s2 = PareTask(title: "Ver serie", scheduledDate: Date(), priority: .low)
    s2.scheduledTime = Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: Date())
    [s1, s2].forEach { context.insert($0) }
    vm.loadDay(for: Date())

    return AddTaskSheet()
        .environment(vm)
        .modelContainer(PareModelContainer.preview)
}

#Preview("Editar Tarea") {
    let context = PareModelContainer.preview.mainContext
    let task = PareTask(title: "Revisar propuesta Q3", scheduledDate: Date(), priority: .high)
    task.scheduledTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())
    task.notes = "Incluir métricas del Q2"
    context.insert(task)

    let vm = DayViewModel(
        taskRepository: TaskRepository(context: context),
        notificationService: NotificationService() // Utilizando tu servicio
    )
    return AddTaskSheet(editingTask: task)
        .environment(vm)
        .modelContainer(PareModelContainer.preview)
}
