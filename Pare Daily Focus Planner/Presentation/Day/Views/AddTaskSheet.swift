// AddTaskSheet.swift
import SwiftUI
import SwiftData

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

    // MARK: - Edit mode (optional)
    var editingTask: PareTask? = nil

    // MARK: - Focus
    @FocusState private var titleFocused: Bool

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Title field
                    titleSection

                    divider

                    // ── Priority picker
                    prioritySection

                    divider

                    // ── Date strip horizontal
                    dateSection

                    divider

                    // ── Time toggle + compact picker
                    timeSection

                    divider

                    // ── Recurrence
                    recurrenceSection

                    divider

                    // ── Notes
                    notesSection

                    // ── Delete button (edit mode only)
                    if editingTask != nil {
                        deleteSection
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(editingTask == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingTask == nil ? "Add" : "Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(title.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.secondary
                        : Color.pareGreen)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            titleFocused = true
            if let task = editingTask { populate(from: task) }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }

    // MARK: - Title section

    private var titleSection: some View {
        CardSection {
            TextField("What do you need to do?", text: $title, axis: .vertical)
                .font(.body)
                .fontWeight(.semibold)
                .focused($titleFocused)
                .submitLabel(.done)
                .lineLimit(1...3)
        }
    }

    // MARK: - Priority section

    private var prioritySection: some View {
        CardSection(header: "Priority") {
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
        CardSection(header: "Date") {
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
        CardSection(header: "Time") {
            Toggle(isOn: $hasTime.animation()) {
                Label("Set a time", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
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
        CardSection(header: "Repeat") {
            Toggle(isOn: $hasRecurrence.animation()) {
                Label("Recurring task", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
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
                                    .foregroundStyle(.primary)
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
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Notes section

    private var notesSection: some View {
        CardSection(header: "Notes") {
            TextField("Add a note...", text: $notes, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(.primary)
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
                Label("Delete Task", systemImage: "trash")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    // MARK: - Divider

    private var divider: some View {
        Color(.separator)
            .frame(height: 0.5)
            .padding(.horizontal, 16)
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
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)

                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected ? .white : .primary)

                Group {
                    if isToday {
                        Text("Today")
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                    } else if isTomorrow {
                        Text("Tmrw")
                            .foregroundStyle(isSelected ? .white.opacity(0.85) : Color.pareGreen)
                    } else {
                        Text(date.formatted(.dateTime.month(.abbreviated)))
                            .foregroundStyle(isSelected ? .white.opacity(0.7) : Color(.tertiaryLabel))
                    }
                }
                .font(.system(size: 8, weight: .semibold))
            }
            .frame(width: 44, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.pareGreen : Color(.tertiarySystemGroupedBackground))
                    .shadow(
                        color: isSelected ? Color.pareGreen.opacity(0.3) : .clear,
                        radius: 6, x: 0, y: 3
                    )
            )
        }
        .buttonStyle(.plain)
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
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, header == nil ? 16 : 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
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
                isSelected
                ? Color.priority(priority).opacity(0.15)
                : Color(.tertiarySystemGroupedBackground)
            )
            .foregroundStyle(
                isSelected ? Color.priority(priority) : Color.secondary
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.priority(priority).opacity(0.4) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
// MARK: - Preview

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
