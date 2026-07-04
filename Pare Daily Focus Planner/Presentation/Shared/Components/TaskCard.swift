// TaskCard.swift
// Presentation/Shared/Components/TaskCard.swift
import SwiftUI
import SwiftData

struct TaskCard: View {

    let task: PareTask
    var style: Style = .standard

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
            .opacity(task.isCompleted ? 0.5 : 1)

            // Contenido
            VStack(alignment: .leading, spacing: 5) {
                // Título
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(task.isCompleted ? Color(hex: "#48484A") : .white)
                    .strikethrough(task.isCompleted, color: Color(hex: "#48484A"))
                    .lineLimit(2)

                // Meta row
                HStack(spacing: 6) {
                    if let time = task.scheduledTime {
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9))
                            Text(time.formatted(.dateTime.hour().minute()))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(task.isCompleted ? Color(hex: "#48484A") : Color.pareGreen)

                        Circle()
                            .fill(Color(hex: "#3A3A3C"))
                            .frame(width: 3, height: 3)
                    }

                    // Priority badge
                    HStack(spacing: 3) {
                        Circle()
                            .fill(Color.priority(task.priority))
                            .frame(width: 5, height: 5)
                        Text(task.priority.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(task.isCompleted
                                     ? Color(hex: "#48484A")
                                     : Color.priority(task.priority).opacity(0.85))
                }

                // Notas
                if let notes = task.notes, !notes.isEmpty, !task.isCompleted {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#636366"))
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 0)

            // Check
            CheckCircle(isCompleted: task.isCompleted, priority: task.priority)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(task.isCompleted
                      ? Color(hex: "#141416")
                      : Color(hex: "#1C1C1E"))
                .overlay {
                    // Liquid Glass rim light — solo borde superior
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
        // Barra de prioridad izquierda
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
        .opacity(task.isCompleted ? 0.65 : 1)
    }

    // MARK: - Compact card

    private var compactCard: some View {
        HStack(spacing: 10) {
            // Barra de prioridad
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
                    .foregroundStyle(task.isCompleted
                                     ? Color(hex: "#48484A")
                                     : Color(hex: "#8E8E93"))
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
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
    }
}

// MARK: - TaskRowView mejorado

struct TaskRowView: View {
    let task: PareTask
    var style: TaskCard.Style = .standard
    var isOverdue: Bool = false
    let onComplete: () -> Void
    let onReschedule: () -> Void
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Badge "From yesterday"
            if isOverdue {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 9, weight: .bold))
                    Text("From yesterday")
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

            TaskCard(task: task, style: style)
                .contentShape(Rectangle())
                .onTapGesture { onTap?() }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onComplete()
            } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
            }
            .tint(Color.pareGreen)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onReschedule()
            } label: {
                Label("Move", systemImage: "calendar.badge.clock")
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

// MARK: - Preview

#Preview {
    let container = PareModelContainer.preview
    let ctx = container.mainContext

    let t1 = PareTask(title: "Enviar factura de mayo", scheduledDate: Date(), priority: .must)
    t1.scheduledTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
    let t2 = PareTask(title: "Revisar propuesta Q3 con el equipo de ventas", scheduledDate: Date(), priority: .high)
    t2.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())
    t2.notes = "Incluir métricas del trimestre anterior"
    let t3 = PareTask(title: "Responder emails pendientes", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Leer 20 páginas", scheduledDate: Date(), priority: .low)
    t4.isCompleted = true
    [t1, t2, t3, t4].forEach { ctx.insert($0) }

    return ZStack {
        Color(hex: "#0C0C0E").ignoresSafeArea()
        ScrollView {
            VStack(spacing: 10) {
                // Standard cards
                TaskRowView(task: t1, onComplete: {}, onReschedule: {})
                TaskRowView(task: t2, onComplete: {}, onReschedule: {})
                TaskRowView(task: t3, isOverdue: true, onComplete: {}, onReschedule: {})
                TaskRowView(task: t4, onComplete: {}, onReschedule: {})

                Divider()
                    .background(Color(hex: "#2A2A2C"))
                    .padding(.vertical, 4)

                // Compact cards
                TaskCard(task: t1, style: .compact)
                TaskCard(task: t2, style: .compact)
                TaskCard(task: t4, style: .compact)
            }
            .padding()
        }
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
