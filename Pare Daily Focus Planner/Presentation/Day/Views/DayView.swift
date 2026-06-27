// DayView.swift
import SwiftUI
import SwiftData

struct DayView: View {

    // MARK: - Environment
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - Local state
    @State private var showAddTask = false
    @State private var taskToEdit: PareTask? = nil
    @State private var showRescheduleFor: PareTask? = nil
    @State private var rescheduleDate = Date()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: []) {

                        // ── Header
                        headerView
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        // ── Banner reagendadas
                        if !dayVM.overdueFromYesterday.isEmpty {
                            rescheduledBanner
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }

                        // ── Tareas de hoy
                        if dayVM.tasksToday.isEmpty {
                            emptyState
                                .padding(.top, 48)
                        } else {
                            tasksSection
                        }

                        // ── Sugerencias del backlog
                        if !dayVM.suggestions.isEmpty {
                            suggestionsSection
                                .padding(.top, 24)
                        }

                        Spacer(minLength: 100)
                    }
                }

                // ── FAB
                fabButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 28)
            }
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
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
            dayVM.loadDay(for: Date())
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.4)

            HStack(alignment: .center) {
                // Progress
                HStack(spacing: 6) {
                    let done  = dayVM.tasksToday.filter(\.isCompleted).count
                    let total = dayVM.tasksToday.count

                    if total > 0 {
                        Text("\(done) of \(total)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(done == total && total > 0 ? Color.pareGreen : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(done == total && total > 0
                                          ? Color.pareGreen.opacity(0.12)
                                          : Color(.tertiarySystemGroupedBackground))
                            )
                    }

                    if dayVM.streak > 0 {
                        Text("🔥 \(dayVM.streak)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.10))
                            )
                    }
                }
            }
            .padding(.top, 6)

            // Progress bar
            if !dayVM.tasksToday.isEmpty {
                let done  = dayVM.tasksToday.filter(\.isCompleted).count
                let total = dayVM.tasksToday.count
                let ratio = Double(done) / Double(total)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemFill))
                            .frame(height: 4)
                        Capsule()
                            .fill(ratio == 1 ? Color.pareGreen : Color.pareGreen.opacity(0.7))
                            .frame(width: geo.size.width * ratio, height: 4)
                            .animation(.spring(duration: 0.4), value: done)
                    }
                }
                .frame(height: 4)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Rescheduled banner

    private var rescheduledBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundStyle(.orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 1) {
                Text("From yesterday")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text("\(dayVM.overdueFromYesterday.count) task\(dayVM.overdueFromYesterday.count > 1 ? "s" : "") moved to today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Tasks section

    private var tasksSection: some View {
        VStack(spacing: 8) {
            ForEach(dayVM.tasksToday) { task in
                TaskRowView(
                    task: task,
                    showsOverdueBadge: dayVM.overdueFromYesterday.contains(where: { $0.id == task.id }),
                    onComplete: {
                        withAnimation(.spring(duration: 0.3)) {
                            dayVM.complete(task)
                        }
                    },
                    onReschedule: {
                        rescheduleDate = Date()
                        showRescheduleFor = task
                    }
                )
                .onTapGesture {
                    taskToEdit = task
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.pareGreen.opacity(0.3))

            Text("No tasks today")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text("Tap + to add your first task")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Suggestions

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dayVM.suggestions.prefix(5)) { task in
                        SuggestionChip(task: task) {
                            withAnimation {
                                dayVM.reschedule(task, to: Date())
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            showAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.pareGreen)
                .clipShape(Circle())
                .shadow(color: Color.pareGreen.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                // TODO: abrir WeekView o date picker
            } label: {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.pareGreen)
            }
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
}

// MARK: - SuggestionChip

private struct SuggestionChip: View {
    let task: PareTask
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.priority(task.priority))
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
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
            VStack(spacing: 0) {
                DatePicker(
                    "New date",
                    selection: $selectedDate,
                    in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.pareGreen)
                .padding()
            }
            .navigationTitle("Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
        .presentationCornerRadius(20)
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let context   = container.mainContext

    let t1 = PareTask(title: "Call the client", scheduledDate: Date(), priority: .must)
    let t2 = PareTask(title: "Review Q3 proposal", scheduledDate: Date(), priority: .high)
    let t3 = PareTask(title: "Reply to emails", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Read 20 pages", scheduledDate: Date(), priority: .low)
    [t1, t2, t3, t4].forEach { context.insert($0) }

    let vm = DayViewModel(
        taskRepository: TaskRepository(context: context),
        notificationService: NotificationService()
    )
    vm.loadDay(for: Date())

    return DayView()
        .environment(vm)
        .modelContainer(container)
}
