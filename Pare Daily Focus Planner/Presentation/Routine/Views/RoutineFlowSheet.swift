//
//  RoutineFlowSheet.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 18/07/2026.
//

import SwiftUI
import SwiftData

// MARK: - Morning Flow Sheet

struct MorningFlowSheet: View {
    @Environment(RoutineViewModel.self) private var routineVM
    @Environment(DayViewModel.self) private var dayVM
    @Environment(\.dismiss) private var dismiss

    @State private var step: Int = 0
    @State private var selectedTaskID: UUID? = nil
    @State private var appear = false

    private let totalSteps = 4

    var body: some View {
        ZStack {
            morningGradientBG.ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra de progreso
                progressBar(current: step, total: totalSteps)
                    .padding(.horizontal, 28)
                    .padding(.top, 24)

                Spacer(minLength: 16)

                // Contenido del paso
                Group {
                    switch step {
                    case 0: morningWelcome
                    case 1: intentionPicker
                    case 2: briefingView
                    default: morningConfirmation
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)

                Spacer(minLength: 24)

                // Botones de navegación
                navButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
        }
        .preferredColorScheme(.dark)
        .presentationCornerRadius(32)
        .onAppear {
            withAnimation(.spring(duration: 0.6)) { appear = true }
        }
    }

    // MARK: - Fondo Morning

    private var morningGradientBG: some View {
        ZStack {
            Color(hex: "#0C0C0E")
            RadialGradient(
                colors: [Color(hex: "#FF9500").opacity(0.15), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
        }
    }

    // MARK: - Paso 0: Bienvenida

    private var morningWelcome: some View {
        VStack(spacing: 20) {
            Text("🌅")
                .font(.system(size: 80))
                .scaleEffect(appear ? 1 : 0.5)
                .animation(.spring(response: 0.7, dampingFraction: 0.6), value: appear)

            VStack(spacing: 8) {
                Text(morningGreeting)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(todayDateString)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: "#FF9500"))
            }

            Text("Tómate 2 minutos para\npreparar un gran día.")
                .font(.body)
                .foregroundStyle(Color(hex: "#8E8E93"))
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Paso 1: Intención del día

    private var intentionPicker: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("¿Cuál es tu intención de hoy?")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Elige 1 tarea que, si la completas,\nel día habrá valido la pena.")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
            .padding(.horizontal, 28)

            let pending = dayVM.tasksToday.filter { !$0.isCompleted }.prefix(6)
            if pending.isEmpty {
                emptyTasksPlaceholder
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(pending)) { task in
                            intentionTaskRow(task)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func intentionTaskRow(_ task: PareTask) -> some View {
        let isSelected = selectedTaskID == task.id
        return Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTaskID = isSelected ? nil : task.id
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.priority(task.priority).opacity(isSelected ? 0.3 : 0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: task.priority.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.priority(task.priority))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if let time = task.scheduledTime {
                        Text(time.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .foregroundStyle(Color(hex: "#8E8E93"))
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color(hex: "#FF9500") : Color(hex: "#3A3A3C"), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "#FF9500"))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                          ? Color(hex: "#FF9500").opacity(0.1)
                          : Color(hex: "#1C1C1E"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color(hex: "#FF9500").opacity(0.5) : Color(hex: "#2A2A2C"),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: isSelected)
    }

    private var emptyTasksPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(Color(hex: "#48484A"))
            Text("No hay tareas para hoy")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "#636366"))
            Text("Puedes añadirlas desde la vista Hoy.")
                .font(.caption)
                .foregroundStyle(Color(hex: "#48484A"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Paso 2: Briefing

    private var briefingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tu briefing de hoy")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Un vistazo rápido antes de empezar.")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }

                // Tarea intención seleccionada
                if let id = selectedTaskID,
                   let task = dayVM.tasksToday.first(where: { $0.id == id }) {
                    briefingSectionHeader("Tu intención de hoy", icon: "⚡")
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#FF9500").opacity(0.2))
                                .frame(width: 38, height: 38)
                            Image(systemName: task.priority.iconName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(hex: "#FF9500"))
                        }
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#FF9500").opacity(0.3), lineWidth: 1))
                }

                // Tareas del día
                let pending = dayVM.tasksToday.filter { !$0.isCompleted }
                if !pending.isEmpty {
                    briefingSectionHeader("Tareas de hoy", icon: "📋")
                    VStack(spacing: 6) {
                        ForEach(pending.prefix(4)) { task in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color.priority(task.priority).opacity(0.7))
                                    .frame(width: 6, height: 6)
                                Text(task.title)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "#EBEBF5"))
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        if pending.count > 4 {
                            Text("+ \(pending.count - 4) más")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "#636366"))
                        }
                    }
                    .padding(14)
                    .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                }

                // Trámites urgentes
                let urgentObs = routineVM.urgentObligations()
                if !urgentObs.isEmpty {
                    briefingSectionHeader("Trámites urgentes", icon: "⚠️")
                    VStack(spacing: 6) {
                        ForEach(urgentObs.prefix(3)) { ob in
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.orange)
                                Text(ob.templateID)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "#EBEBF5"))
                                    .lineLimit(1)
                                Spacer()
                                if let days = ob.daysUntilExpiry {
                                    Text(days == 0 ? "Hoy" : "\(days)d")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(days <= 1 ? .red : .orange)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func briefingSectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Text(icon).font(.system(size: 14))
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "#8E8E93"))
                .textCase(.uppercase)
                .kerning(0.8)
        }
    }

    // MARK: - Paso 3: Confirmación

    private var morningConfirmation: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF9500").opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(Color(hex: "#FF9500"))
                    .scaleEffect(appear ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appear)
            }

            VStack(spacing: 8) {
                Text("¡Plan listo! 🎯")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tienes todo lo que necesitas\npara un día con propósito.")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1)) { appear = true }
        }
    }

    // MARK: - Navegación

    private var navButtons: some View {
        HStack(spacing: 16) {
            if step > 0 {
                Button {
                    withAnimation(.spring(duration: 0.4)) { step -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: "#8E8E93"))
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }

            Button {
                if step < totalSteps - 1 {
                    withAnimation(.spring(duration: 0.4)) { step += 1 }
                } else {
                    routineVM.completeMorning(intentionTaskID: selectedTaskID)
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(step == totalSteps - 1 ? "Comenzar el día" : "Continuar")
                        .font(.system(size: 17, weight: .semibold))
                    if step < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FFB340"), Color(hex: "#FF9500")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: Color(hex: "#FF9500").opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(SpringButtonStyle())
        }
    }

    // MARK: - Helpers

    private var morningGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Buenos días 👋" }
        return "Buenas tardes 👋"
    }

    private var todayDateString: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide))
            .capitalized
    }
}

// MARK: - Evening Flow Sheet

struct EveningFlowSheet: View {
    @Environment(RoutineViewModel.self) private var routineVM
    @Environment(DayViewModel.self) private var dayVM
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step: Int = 0
    @State private var carriedTasks: Set<UUID> = []
    @State private var quickCaptureTitle: String = ""
    @State private var eveningNote: String = ""
    @State private var appear = false
    @State private var newTaskAdded = false

    private let totalSteps = 4

    var body: some View {
        ZStack {
            eveningGradientBG.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar(current: step, total: totalSteps)
                    .padding(.horizontal, 28)
                    .padding(.top, 24)

                Spacer(minLength: 16)

                Group {
                    switch step {
                    case 0: eveningIntro
                    case 1: completedReview
                    case 2: pendingReview
                    case 3: quickCaptureAndNote
                    default: eveningConfirmation
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)

                Spacer(minLength: 24)

                navButtonsEvening
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
        }
        .preferredColorScheme(.dark)
        .presentationCornerRadius(32)
        .onAppear {
            withAnimation(.spring(duration: 0.6)) { appear = true }
        }
    }

    // MARK: - Fondo Evening

    private var eveningGradientBG: some View {
        ZStack {
            Color(hex: "#0C0C0E")
            RadialGradient(
                colors: [Color(hex: "#5E5CE6").opacity(0.15), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
        }
    }

    // MARK: - Paso 0: Intro Evening

    private var eveningIntro: some View {
        VStack(spacing: 20) {
            Text("🌙")
                .font(.system(size: 80))
                .scaleEffect(appear ? 1 : 0.5)
                .animation(.spring(response: 0.7, dampingFraction: 0.6), value: appear)

            VStack(spacing: 8) {
                Text("Revisión del día")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("2 minutos para cerrar bien\neste día.")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .multilineTextAlignment(.center)
            }

            // Mini stats
            let tasks = routineVM.tasksForToday()
            let completed = tasks.filter(\.isCompleted)
            HStack(spacing: 20) {
                eveningStatPill(value: "\(completed.count)", label: "completadas", color: Color(hex: "#5E5CE6"))
                eveningStatPill(value: "\(tasks.count - completed.count)", label: "pendientes", color: Color(hex: "#FF9500"))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 32)
    }

    private func eveningStatPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color(hex: "#8E8E93"))
        }
        .frame(width: 110, height: 80)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Paso 1: Completadas

    private var completedReview: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Lo que lograste hoy ✅")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 28)

            let completed = routineVM.tasksForToday().filter(\.isCompleted)
            if completed.isEmpty {
                VStack(spacing: 12) {
                    Text("😶")
                        .font(.system(size: 48))
                    Text("No hay tareas completadas hoy.")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#636366"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(completed) { task in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: "#5E5CE6"))
                                    .font(.system(size: 18))
                                Text(task.title)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(hex: "#EBEBF5"))
                                    .lineLimit(2)
                                    .strikethrough(true, color: Color(hex: "#636366"))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Paso 2: Pendientes

    private var pendingReview: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("¿Qué pasa a mañana?")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Selecciona las tareas que\npostpones a mañana.")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
            .padding(.horizontal, 28)

            let pending = routineVM.tasksForToday().filter { !$0.isCompleted }
            if pending.isEmpty {
                VStack(spacing: 12) {
                    Text("🎉")
                        .font(.system(size: 48))
                    Text("Todo completado.\n¡Día perfecto!")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "#5E5CE6"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(pending) { task in
                            carryOverRow(task)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func carryOverRow(_ task: PareTask) -> some View {
        let selected = carriedTasks.contains(task.id)
        return Button {
            withAnimation(.spring(duration: 0.25)) {
                if selected { carriedTasks.remove(task.id) }
                else { carriedTasks.insert(task.id) }
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.priority(task.priority).opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: task.priority.iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.priority(task.priority))
                }
                Text(task.title)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Spacer()
                Image(systemName: selected ? "arrow.uturn.right.circle.fill" : "circle")
                    .foregroundStyle(selected ? Color(hex: "#5E5CE6") : Color(hex: "#48484A"))
                    .font(.system(size: 22))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                selected ? Color(hex: "#5E5CE6").opacity(0.1) : Color(hex: "#1C1C1E"),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        selected ? Color(hex: "#5E5CE6").opacity(0.4) : Color(hex: "#2A2A2C"),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.25), value: selected)
    }

    // MARK: - Paso 3: Quick capture + nota

    private var quickCaptureAndNote: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Captura y reflexión")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Añade tareas para mañana y deja\nuna nota del día.")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                }

                // Quick capture
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text("⚡")
                        Text("Tarea para mañana")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .textCase(.uppercase)
                            .kerning(0.8)
                    }

                    HStack(spacing: 12) {
                        TextField("¿Qué tienes que hacer mañana?", text: $quickCaptureTitle)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .submitLabel(.done)
                            .onSubmit { addQuickCaptureTask() }

                        if !quickCaptureTitle.isEmpty {
                            Button(action: addQuickCaptureTask) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color(hex: "#5E5CE6"))
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1))

                    if newTaskAdded {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(hex: "#5E5CE6"))
                            Text("Tarea añadida para mañana")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color(hex: "#5E5CE6"))
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // Nota del día
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text("✍️")
                        Text("¿Qué fue lo más importante?")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .textCase(.uppercase)
                            .kerning(0.8)
                    }

                    TextField("Opcional — una reflexión del día...", text: $eveningNote, axis: .vertical)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(3...5)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(Color(hex: "#1C1C1E"), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#2A2A2C"), lineWidth: 1))
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func addQuickCaptureTask() {
        let title = quickCaptureTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let task = PareTask(title: title, scheduledDate: tomorrow, priority: .medium)
        dayVM.addTask(task)
        
        quickCaptureTitle = ""
        withAnimation(.spring(duration: 0.3)) { newTaskAdded = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { newTaskAdded = false }
        }
    }

    // MARK: - Paso 4: Confirmación

    private var eveningConfirmation: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#5E5CE6").opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(hex: "#BF5AF2"))
                    .scaleEffect(appear ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appear)
            }

            VStack(spacing: 8) {
                Text("¡Buen descanso! 🌙")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Has cerrado el día con intención.\nMañana será otro gran día.")
                    .font(.body)
                    .foregroundStyle(Color(hex: "#8E8E93"))
                    .multilineTextAlignment(.center)
            }

            if routineVM.streakDays > 0 {
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.system(size: 20))
                    Text("\(routineVM.streakDays + 1) días de racha")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#FF9500"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "#FF9500").opacity(0.1), in: Capsule())
                .overlay(Capsule().strokeBorder(Color(hex: "#FF9500").opacity(0.3), lineWidth: 1))
            }
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1)) { appear = true }
        }
    }

    // MARK: - Navegación Evening

    private var navButtonsEvening: some View {
        HStack(spacing: 16) {
            if step > 0 {
                Button {
                    withAnimation(.spring(duration: 0.4)) { step -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: "#8E8E93"))
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }

            Button {
                if step < totalSteps - 1 {
                    withAnimation(.spring(duration: 0.4)) { step += 1 }
                } else {
                    let tasks = dayVM.tasksToday.filter { carriedTasks.contains($0.id) }
                    routineVM.completeEvening(note: eveningNote, carriedOverTasks: tasks)
                    dayVM.loadDay(for: dayVM.selectedDate)
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(step == totalSteps - 1 ? "Cerrar el día" : "Continuar")
                        .font(.system(size: 17, weight: .semibold))
                    if step < totalSteps - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#5E5CE6"), Color(hex: "#BF5AF2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: Color(hex: "#5E5CE6").opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(SpringButtonStyle())
        }
    }
}

// MARK: - Barra de progreso compartida

private func progressBar(current: Int, total: Int) -> some View {
    GeometryReader { geo in
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(hex: "#2A2A2C"))
                .frame(height: 3)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF9500"), Color(hex: "#FFD60A")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geo.size.width * CGFloat(current + 1) / CGFloat(total), height: 3)
                .animation(.spring(duration: 0.5), value: current)
        }
    }
    .frame(height: 3)
}
