//
//  RoutineView.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 18/07/2026.
//

import SwiftUI
import SwiftData

struct RoutineView: View {

    // MARK: - Environment
    @Environment(RoutineViewModel.self) private var routineVM
    @Environment(DayViewModel.self) private var dayVM

    // MARK: - State
    @State private var streakPulse = false
    @State private var appeared = false

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                        .padding(.top, 16)

                    streakCard
                        .padding(.horizontal, 20)

                    HStack(spacing: 14) {
                        morningCard
                        eveningCard
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { routineVM.showMorningFlow },
            set: { routineVM.showMorningFlow = $0 }
        ), onDismiss: {
            routineVM.loadStreakAndStatus()
        }) {
            MorningFlowSheet()
                .environment(routineVM)
                .environment(dayVM)
        }
        .sheet(isPresented: Binding(
            get: { routineVM.showEveningFlow },
            set: { routineVM.showEveningFlow = $0 }
        ), onDismiss: {
            routineVM.loadStreakAndStatus()
        }) {
            EveningFlowSheet()
                .environment(routineVM)
                .environment(dayVM)
        }
        .onAppear {
            routineVM.loadStreakAndStatus()
            withAnimation(.spring(duration: 0.7)) { appeared = true }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                streakPulse = true
            }
        }
    }

    // MARK: - Fondo

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0D0D10"), Color(hex: "#080809")],
                startPoint: .top,
                endPoint: .bottom
            )
            // Glow morning top
            RadialGradient(
                colors: [Color(hex: "#FF9500").opacity(0.07), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            // Glow evening bottom
            RadialGradient(
                colors: [Color(hex: "#5E5CE6").opacity(0.07), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Rutina diaria")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("El ritual que cierra el ciclo de tu día")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "#636366"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF9500").opacity(streakPulse ? 0.2 : 0.1))
                        .frame(width: 56, height: 56)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: streakPulse)
                    Text("🔥")
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(routineVM.streakDays)")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "#FF9500"))
                            .contentTransition(.numericText())

                        Text(routineVM.streakDays == 1 ? "día seguido" : "días seguidos")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(hex: "#8E8E93"))
                            .padding(.bottom, 4)
                    }

                    Text("Racha de rutinas completadas")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#636366"))
                }

                Spacer()

                // Estado hoy
                VStack(spacing: 6) {
                    statusDot(completed: routineVM.todayMorningCompleted, icon: "🌅")
                    statusDot(completed: routineVM.todayEveningCompleted, icon: "🌙")
                }
            }

            // Barra de progreso del día
            let bothDone = routineVM.todayMorningCompleted && routineVM.todayEveningCompleted
            let morningDone = routineVM.todayMorningCompleted
            let progress: Double = bothDone ? 1.0 : morningDone ? 0.5 : 0.0
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "#2A2A2C"))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: bothDone
                                        ? [Color(hex: "#5E5CE6"), Color(hex: "#BF5AF2")]
                                        : [Color(hex: "#FF9500"), Color(hex: "#FFD60A")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress)
                            .animation(.spring(duration: 0.6), value: progress)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text(bothDone ? "Día completo ✓" : morningDone ? "Mañana lista — Queda el cierre" : "Sin rituales completados hoy")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#636366"))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.05), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(hex: "#FF9500").opacity(0.2), Color(hex: "#5E5CE6").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .offset(y: appeared ? 0 : 20)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(duration: 0.6).delay(0.1), value: appeared)
    }

    private func statusDot(completed: Bool, icon: String) -> some View {
        HStack(spacing: 5) {
            Text(icon).font(.system(size: 12))
            Circle()
                .fill(completed ? Color(hex: "#30D158") : Color(hex: "#3A3A3C"))
                .frame(width: 8, height: 8)
        }
    }

    // MARK: - Morning Card

    private var morningCard: some View {
        routineCardButton(
            emoji: "🌅",
            title: "Mañana",
            subtitle: routineVM.todayMorningCompleted ? "Completada" : morningSubtitle,
            accentColor: Color(hex: "#FF9500"),
            secondaryColor: Color(hex: "#FFD60A"),
            isCompleted: routineVM.todayMorningCompleted,
            isAvailable: !routineVM.todayMorningCompleted,
            delayIndex: 0
        ) {
            routineVM.showMorningFlow = true
        }
    }

    // MARK: - Evening Card

    private var eveningCard: some View {
        routineCardButton(
            emoji: "🌙",
            title: "Noche",
            subtitle: routineVM.todayEveningCompleted ? "Completada" : eveningSubtitle,
            accentColor: Color(hex: "#5E5CE6"),
            secondaryColor: Color(hex: "#BF5AF2"),
            isCompleted: routineVM.todayEveningCompleted,
            isAvailable: !routineVM.todayEveningCompleted,
            delayIndex: 1
        ) {
            routineVM.showEveningFlow = true
        }
    }

    private func routineCardButton(
        emoji: String,
        title: String,
        subtitle: String,
        accentColor: Color,
        secondaryColor: Color,
        isCompleted: Bool,
        isAvailable: Bool,
        delayIndex: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: isAvailable ? action : {}) {
            VStack(alignment: .leading, spacing: 14) {
                // Emoji + estado
                HStack {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(isCompleted ? 0.25 : 0.15))
                            .frame(width: 48, height: 48)
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(accentColor)
                        } else {
                            Text(emoji)
                                .font(.system(size: 22))
                        }
                    }
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(accentColor)
                            .font(.system(size: 16))
                    } else if isAvailable {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color(hex: "#636366"))
                            .font(.system(size: 12, weight: .semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(isCompleted ? accentColor : Color(hex: "#8E8E93"))
                        .lineLimit(2)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: "#141416"))
                    .overlay {
                        if isCompleted {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [accentColor.opacity(0.12), secondaryColor.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(
                                isCompleted
                                    ? LinearGradient(colors: [accentColor.opacity(0.5), secondaryColor.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color(hex: "#2C2C2E"), Color(hex: "#1C1C1E")], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1.2
                            )
                    }
            }
        }
        .buttonStyle(SpringButtonStyle())
        .disabled(isCompleted)
        .offset(y: appeared ? 0 : 24)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(duration: 0.6).delay(Double(delayIndex) * 0.08 + 0.2), value: appeared)
    }

    // MARK: - Subtítulos dinámicos

    private var morningSubtitle: String {
        let h = routineVM.morningHour
        let m = routineVM.morningMinute
        let timeStr = String(format: "%02d:%02d", h, m)
        return "Preparar el día · \(timeStr)"
    }

    private var eveningSubtitle: String {
        let h = routineVM.eveningHour
        let m = routineVM.eveningMinute
        let timeStr = String(format: "%02d:%02d", h, m)
        return "Revisar y cerrar · \(timeStr)"
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let context = container.mainContext
    let taskRepo = TaskRepository(context: context)
    let routineVM = RoutineViewModel(context: context, taskRepository: taskRepo)
    let dayVM = DayViewModel(taskRepository: taskRepo, notificationService: NotificationService())

    return RoutineView()
        .environment(routineVM)
        .environment(dayVM)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
