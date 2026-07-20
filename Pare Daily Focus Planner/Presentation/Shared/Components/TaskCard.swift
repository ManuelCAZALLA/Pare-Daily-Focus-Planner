// TaskCard.swift
// Presentation/Shared/Components/TaskCard.swift
import SwiftUI
import SwiftData

struct TaskCard: View {

    let task: PareTask
    var style: Style = .standard
    var onComplete: (() -> Void)? = nil

    enum Style {
        case standard
        case compact
    }

    var body: some View {
        switch style {
        case .standard: standardCard
        case .compact:  compactCard
        }
    }

    // MARK: - Standard card

    private var standardCard: some View {
        HStack(alignment: .center, spacing: 12) {

            // Icono
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.priority(task.priority).opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                Color.priority(task.priority).opacity(0.25),
                                lineWidth: 0.8
                            )
                    )

                Image(systemName: task.priority.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.priority(task.priority))
            }
            .opacity(task.isCompleted ? 0.4 : 1)

            // Contenido
            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(task.isCompleted ? Color(hex: "#48484A") : .white)
                    .strikethrough(task.isCompleted, color: Color(hex: "#48484A"))
                    .lineLimit(2)

                // ── Fila de metadatos ──────────────────────────────────────
                // Usamos layoutPriority para que la etiqueta de prioridad
                // nunca se parta: si no cabe todo, se trunca el label pero
                // permanece en la misma línea.
                HStack(spacing: 0) {
                    if let time = task.scheduledTime {
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9))
                            Text(time.formatted(.dateTime.hour().minute()))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(task.isCompleted
                                         ? Color(hex: "#48484A")
                                         : Color.pareGreen)
                        .fixedSize()           // la hora nunca se trunca ni parte

                        Circle()
                            .fill(Color(hex: "#3A3A3C"))
                            .frame(width: 3, height: 3)
                            .padding(.horizontal, 6)
                    }

                    HStack(spacing: 3) {
                        Circle()
                            .fill(Color.priority(task.priority))
                            .frame(width: 5, height: 5)
                            .flexibleFrame()
                        Text(task.priority.label)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)      // nunca rompe a segunda línea
                            .minimumScaleFactor(0.85)  // se encoge un poco antes de truncar
                    }
                    .foregroundStyle(task.isCompleted
                                     ? Color(hex: "#48484A")
                                     : Color.priority(task.priority).opacity(0.85))
                }

                if let notes = task.notes, !notes.isEmpty, !task.isCompleted {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#636366"))
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)  // ocupa el espacio disponible
            // sin Spacer suelto — el frame+alignment ya empuja el check a la derecha

            // Check — tappable directamente
            Button {
                onComplete?()
            } label: {
                CheckCircle(isCompleted: task.isCompleted, priority: task.priority)
            }
            .buttonStyle(.plain)
            .disabled(onComplete == nil)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(task.isCompleted ? Color(hex: "#141416") : Color(hex: "#1C1C1E"))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(task.isCompleted ? 0.02 : 0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(task.isCompleted ? 0.04 : 0.09),
                                    Color(hex: "#38383A").opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                }
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.priority(task.priority),
                            Color.priority(task.priority).opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .padding(.vertical, 14)
                .opacity(task.isCompleted ? 0.3 : 1)
        }
        .opacity(task.isCompleted ? 0.55 : 1)
    }

    // MARK: - Compact card

    private var compactCard: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.priority(task.priority))
                .frame(width: 3, height: 28)
                .opacity(task.isCompleted ? 0.3 : 1)

            Text(task.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(task.isCompleted ? Color(hex: "#48484A") : .white)
                .strikethrough(task.isCompleted)
                .lineLimit(1)

            Spacer()

            if let time = task.scheduledTime {
                Text(time.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(task.isCompleted ? Color(hex: "#48484A") : Color(hex: "#8E8E93"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1C1C1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "#38383A").opacity(0.7), lineWidth: 0.5)
                )
        )
        .opacity(task.isCompleted ? 0.6 : 1)
    }
}

// MARK: - CheckCircle

struct CheckCircle: View {
    let isCompleted: Bool
    let priority: Priority

    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.pareGreen : Color(hex: "#2C2C2E"))
                .frame(width: 28, height: 28)

            Circle()
                .strokeBorder(
                    isCompleted ? Color.pareGreen : Color(hex: "#545456"),
                    lineWidth: 1.5
                )
                .frame(width: 28, height: 28)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
    }
}

// MARK: - TaskRowView

struct TaskRowView: View {
    let task: PareTask
    var style: TaskCard.Style = .standard
    var isOverdue: Bool = false
    let onComplete: () -> Void
    let onReschedule: () -> Void
    var onTap: (() -> Void)? = nil

    @Environment(DayViewModel.self) private var dayVM

    private var isCompleting: Bool {
        dayVM.completingTaskIDs.contains(task.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isOverdue {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 9, weight: .bold))
                    Text("De ayer")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.12))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.orange.opacity(0.25), lineWidth: 0.5)
                        )
                )
                .padding(.leading, 4)
            }

            TaskCard(task: task, style: style, onComplete: onComplete)
                .contentShape(Rectangle())
                .onTapGesture { onTap?() }
        }
        .scaleEffect(isCompleting ? 0.94 : 1)
        .opacity(isCompleting ? 0 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCompleting)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onComplete()
            } label: {
                Label("Hecho", systemImage: "checkmark.circle.fill")
            }
            .tint(Color.pareGreen)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onReschedule()
            } label: {
                Label("Mover", systemImage: "calendar.badge.clock")
            }
            .tint(Color(hex: "#007AFF"))
        }
    }
}

// MARK: - Priority icon

extension Priority {
    var iconName: String {
        switch self {
        case .low:    return "minus.circle.fill"
        case .medium: return "circle.fill"
        case .high:   return "arrow.up.circle.fill"
        case .must:   return "exclamationmark.circle.fill"
        }
    }
}

// MARK: - View helper

private extension View {
    /// Evita que el punto separador de prioridad se expanda
    func flexibleFrame() -> some View {
        self.fixedSize()
    }
}

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let ctx = container.mainContext

    let t1 = PareTask(title: "Enviar factura de mayo", scheduledDate: Date(), priority: .must)
    t1.scheduledTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
    let t2 = PareTask(title: "Revisar propuesta Q3 con el equipo", scheduledDate: Date(), priority: .high)
    t2.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())
    t2.notes = "Incluir métricas del trimestre anterior"
    let t3 = PareTask(title: "Responder emails pendientes", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Leer 20 páginas", scheduledDate: Date(), priority: .low)
    [t1, t2, t3, t4].forEach { ctx.insert($0) }

    let vm = DayViewModel(
        taskRepository: TaskRepository(context: ctx),
        notificationService: NotificationService()
    )
    vm.loadDay(for: Date())

    return ZStack {
        Color(hex: "#0C0C0E").ignoresSafeArea()
        ScrollView {
            VStack(spacing: 10) {
                TaskRowView(task: t1, onComplete: { vm.complete(t1) }, onReschedule: {})
                TaskRowView(task: t2, onComplete: { vm.complete(t2) }, onReschedule: {})
                TaskRowView(task: t3, isOverdue: true, onComplete: { vm.complete(t3) }, onReschedule: {})
                TaskRowView(task: t4, onComplete: { vm.complete(t4) }, onReschedule: {})
            }
            .padding()
        }
    }
    .environment(vm)
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
