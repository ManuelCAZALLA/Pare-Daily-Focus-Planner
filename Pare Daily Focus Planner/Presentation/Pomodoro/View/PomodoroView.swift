//
//  PomodoroView.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 04/07/2026.
//

import SwiftUI
import SwiftData

struct PomodoroView: View {

    // MARK: - Environment
    @Environment(PomodoroViewModel.self) private var vm
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - State
    @State private var showTaskPicker     = false
    @State private var showSessionConfig  = false
    @State private var ringPulse          = false
    @State private var sessionFlash       = false

    // MARK: - Body
    var body: some View {
        ZStack {
            // ── Background
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: 20)

                // ── Task selector pill
                taskSelectorPill
                    .padding(.horizontal, 24)

                Spacer(minLength: 32)

                // ── Timer ring
                timerRing
                    .frame(width: 280, height: 280)

                Spacer(minLength: 36)

                // ── Controls
                controlButtons

                Spacer(minLength: 28)

                // ── Session config
                sessionConfigCard
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)

                // ── Stats strip
                statsStrip
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(selectedTask: Binding(
                get: { vm.activeTask },
                set: { vm.selectTask($0) }
            ))
        }
        .onChange(of: vm.isRunning) { _, running in
            withAnimation(.easeInOut(duration: 0.6)) {
                ringPulse = running
            }
        }
        .onChange(of: vm.sessionsCompleted) { old, new in
            if new > old {
                withAnimation(.easeInOut(duration: 0.15)) {
                    sessionFlash = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation { sessionFlash = false }
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "#0C0C0E").ignoresSafeArea()

            // Glow radial detrás del timer
            RadialGradient(
                colors: [
                    Color(hex: sessionColor).opacity(ringPulse ? 0.10 : 0.04),
                    Color.clear
                ],
                center: .center,
                startRadius: 60,
                endRadius: 320
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: ringPulse)
        }
    }

    // MARK: - Task selector pill

    private var taskSelectorPill: some View {
        Button {
            showTaskPicker = true
        } label: {
            HStack(spacing: 10) {
                if let task = vm.activeTask {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.priority(task.priority).opacity(0.15))
                            .frame(width: 30, height: 30)
                        Image(systemName: task.priority.iconName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.priority(task.priority))
                    }

                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                } else {
                    Image(systemName: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                    Text("Selecciona una tarea")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#48484A"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.07), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.14), Color.white.opacity(0.03)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Timer ring

    private var timerRing: some View {
        ZStack {
            // Glass backing circle
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.05), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                }

            // Track
            Circle()
                .stroke(Color(hex: "#2A2A2C"), lineWidth: 10)
                .padding(20)

            // Progress arc
            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    AngularGradient(
                        colors: [Color(hex: "#4ADE80"), Color(hex: "#22C55E"), Color(hex: "#15803D")],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle:   .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(20)
                .shadow(color: Color(hex: sessionColor).opacity(0.55), radius: 10)
                .animation(.linear(duration: 1), value: vm.progress)

            // Flash overlay al completar sesión
            if sessionFlash {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .padding(20)
                    .transition(.opacity)
            }

            // Centro
            VStack(spacing: 6) {
                // Tiempo
                Text(vm.timeString)
                    .font(.system(size: 54, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                // Label sesión
                Text(vm.sessionLabel.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: sessionColor))
                    .kerning(1.5)

                // Session dots
                HStack(spacing: 8) {
                    ForEach(0..<vm.sessionsPerRound, id: \.self) { i in
                        Circle()
                            .fill(i < vm.sessionsCompleted
                                  ? Color(hex: "#22C55E")
                                  : Color(hex: "#2A2A2C"))
                            .frame(width: 7, height: 7)
                            .animation(.spring(duration: 0.3), value: vm.sessionsCompleted)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Control buttons

    private var controlButtons: some View {
        HStack(spacing: 24) {

            // Skip
            GlassCircleButton(
                size: 54,
                icon: "backward.end.fill",
                iconSize: 16
            ) {
                vm.skip()
            }

            // Play / Pause — principal
            Button {
                vm.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(vm.isRunning
                              ? Color(hex: "#1A1A1C")
                              : Color(hex: "#22C55E"))
                        .overlay {
                            if vm.isRunning {
                                Circle()
                                    .strokeBorder(Color(hex: "#22C55E"), lineWidth: 2)
                            }
                        }
                        .frame(width: 74, height: 74)
                        .shadow(
                            color: Color(hex: "#22C55E").opacity(vm.isRunning ? 0.45 : 0.3),
                            radius: vm.isRunning ? 20 : 10
                        )

                    Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .offset(x: vm.isRunning ? 0 : 2)
                }
            }
            .buttonStyle(SpringButtonStyle())

            // Reset
            GlassCircleButton(
                size: 54,
                icon: "arrow.counterclockwise",
                iconSize: 17
            ) {
                vm.reset()
            }
        }
    }

    // MARK: - Session config card

    private var sessionConfigCard: some View {
        HStack(spacing: 0) {
            ConfigItem(
                icon: "🍅",
                value: "\(vm.focusDuration) min",
                label: "Enfoque",
                options: [15, 20, 25, 30, 45, 60],
                current: vm.focusDuration
            ) { vm.setFocusDuration($0) }

            configDivider

            ConfigItem(
                icon: "☕",
                value: "\(vm.shortBreakDuration) min",
                label: "Descanso",
                options: [3, 5, 10, 15],
                current: vm.shortBreakDuration
            ) { vm.setShortBreak($0) }

            configDivider

            ConfigItem(
                icon: "🔁",
                value: "\(vm.sessionsPerRound)x",
                label: "Rondas",
                options: [2, 3, 4, 6],
                current: vm.sessionsPerRound
            ) { vm.setSessionsPerRound($0) }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                }
        }
    }

    private var configDivider: some View {
        Rectangle()
            .fill(Color(hex: "#2A2A2C"))
            .frame(width: 0.5)
            .padding(.vertical, 6)
    }

    // MARK: - Stats strip

    private var statsStrip: some View {
        HStack(spacing: 20) {
            StatChip(icon: "🍅", value: "\(vm.totalSessionsToday)", label: "hoy")
            StatChip(icon: "⏱", value: formatFocusTime(vm.totalFocusTimeToday), label: "focus")
            StatChip(icon: "🔥", value: "\(vm.focusStreakDays)", label: "días")
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var sessionColor: String {
        vm.sessionColor
    }

    private func formatFocusTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

// MARK: - GlassCircleButton

private struct GlassCircleButton: View {
    let size: CGFloat
    let icon: String
    let iconSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.06), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.8
                            )
                    }
                    .frame(width: size, height: size)

                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - SpringButtonStyle

/*private struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.91 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}*/

// MARK: - ConfigItem

private struct ConfigItem: View {
    let icon: String
    let value: String
    let label: String
    let options: [Int]
    let current: Int
    let onChange: (Int) -> Void

    @State private var showPicker = false

    private var dialogTitle: String {
        switch label {
        case "Enfoque": return String(localized: "Ajustar enfoque")
        case "Descanso": return String(localized: "Ajustar descanso")
        case "Rondas": return String(localized: "Ajustar rondas")
        default: return "Ajustar \(label)"
        }
    }

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                showPicker.toggle()
            }
        } label: {
            VStack(spacing: 3) {
                Text(icon)
                    .font(.system(size: 18))
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text(LocalizedStringKey(label))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .confirmationDialog(dialogTitle, isPresented: $showPicker) {
            ForEach(options, id: \.self) { opt in
                Button(label == "Rondas" ? String(localized: "\(opt) rondas") : String(localized: "\(opt) min")) {
                    onChange(opt)
                }
            }
            Button(String(localized: "Cancelar"), role: .cancel) {}
        }
    }
}

// MARK: - StatChip

private struct StatChip: View {
    let icon: String
    let value: String
    let label: LocalizedStringKey

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 12))
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "#48484A"))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#38383A"))
        }
    }
}

// MARK: - TaskPickerSheet

struct TaskPickerSheet: View {
    @Binding var selectedTask: PareTask?
    @Environment(DayViewModel.self) private var dayVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0C0C0E").ignoresSafeArea()

                if dayVM.tasksToday.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(hex: "#48484A"))
                        Text("No hay tareas hoy")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "#8E8E93"))
                    }
                } else {
                    List(dayVM.tasksToday.filter { !$0.isCompleted }) { task in
                        Button {
                            selectedTask = task
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.priority(task.priority).opacity(0.15))
                                        .frame(width: 34, height: 34)
                                    Image(systemName: task.priority.iconName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.priority(task.priority))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    if let time = task.scheduledTime {
                                        Text(time.formatted(.dateTime.hour().minute()))
                                            .font(.caption)
                                            .foregroundStyle(Color(hex: "#8E8E93"))
                                    }
                                }

                                Spacer()

                                if selectedTask?.id == task.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(hex: "#22C55E"))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color(hex: "#1A1A1C"))
                        .listRowSeparatorTint(Color(hex: "#2A2A2C"))
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Enfocar en...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#0C0C0E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ninguno") {
                        selectedTask = nil
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "#8E8E93"))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let context   = container.mainContext

    let t1 = PareTask(title: "Implementar PomodoroView", scheduledDate: Date(), priority: .must)
    t1.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())
    let t2 = PareTask(title: "Revisar pull request", scheduledDate: Date(), priority: .high)
    [t1, t2].forEach { context.insert($0) }

    let pomVM = PomodoroViewModel(
        repository: FocusSessionRepository(context: context)
    )
    pomVM.activeTask          = t1
    pomVM.sessionsCompleted   = 2
    pomVM.totalSessionsToday  = 3
    pomVM.totalFocusTimeToday = 75 * 60
    pomVM.focusStreakDays      = 4

    let dayVM = DayViewModel(
        taskRepository: TaskRepository(context: context),
        notificationService: NotificationService()
    )
    dayVM.loadDay(for: Date())

    return PomodoroView()
        .environment(pomVM)
        .environment(dayVM)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
