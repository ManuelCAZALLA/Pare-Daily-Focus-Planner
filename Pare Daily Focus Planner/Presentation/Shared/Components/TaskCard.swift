// TaskCard.swift
// Presentation/Shared/Components/TaskCard.swift
import SwiftUI
import SwiftData

struct TaskCard: View {

    let task: PareTask
    var style: Style = .standard

    enum Style {
        case standard   // timeline card completa
        case compact    // fila corta para sugerencias / week view
    }

    var body: some View {
        switch style {
        case .standard: standardCard
        case .compact:  compactCard
        }
    }

    // MARK: - Standard card (timeline)

    private var standardCard: some View {
        HStack(alignment: .center, spacing: 12) {

            // Icono — 44×44 tap area con visual 42pt
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.priorityBackground(task.priority))
                    .frame(width: 44, height: 44)

                Image(systemName: task.priority.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.priority(task.priority))
            }

            // Contenido
            VStack(alignment: .leading, spacing: 4) {
                // Meta (hora + prioridad)
                HStack(spacing: 6) {
                    if let time = task.scheduledTime {
                        Label(time.formatted(.dateTime.hour().minute()), systemImage: "clock")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.pareGreen)
                    }

                    if task.scheduledTime != nil {
                        Text("·")
                            .foregroundStyle(Color(hex: "#636366"))
                            .font(.caption)
                    }

                    Text(task.priority.label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "#AEAEB2"))
                }

                // Título
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        task.isCompleted
                        ? Color(hex: "#636366")
                        : Color.white
                    )
                    .strikethrough(task.isCompleted, color: Color(hex: "#636366"))
                    .lineLimit(2)

                // Notas
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#8E8E93"))
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 0)

            // Check button — 44×44 tappable
            CheckCircle(isCompleted: task.isCompleted, priority: task.priority)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1C1C1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "#38383A"), lineWidth: 0.5)
                )
        )
        .overlay(alignment: .leading) {
            // Barra de prioridad izquierda
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.priority(task.priority))
                .frame(width: 3)
                .padding(.vertical, 12)
        }
        .opacity(task.isCompleted ? 0.5 : 1)
    }

    // MARK: - Compact card

    private var compactCard: some View {
        HStack(spacing: 12) {
            // Dot indicator con color de prioridad
            Circle()
                .fill(Color.priority(task.priority))
                .frame(width: 8, height: 8)

            Text(task.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(
                    task.isCompleted
                    ? Color(hex: "#636366")
                    : Color.white
                )
                .strikethrough(task.isCompleted)
                .lineLimit(1)

            Spacer()

            if let time = task.scheduledTime {
                Text(time.formatted(.dateTime.hour().minute()))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "#8E8E93"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1C1C1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "#38383A"), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - CheckCircle

struct CheckCircle: View {
    let isCompleted: Bool
    let priority: Priority

    var body: some View {
        // Área tappable mínima 44×44pt (Apple HIG)
        ZStack {
            // Fondo sutil para no-completado — mejora visibilidad en dark mode
            Circle()
                .fill(isCompleted ? Color.pareGreen : Color(hex: "#2C2C2E"))
                .frame(width: 28, height: 28)

            Circle()
                .strokeBorder(
                    isCompleted ? Color.pareGreen : Color(hex: "#636366"),
                    lineWidth: 2
                )
                .frame(width: 28, height: 28)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 44, height: 44) // tap area HIG compliant
        .contentShape(Circle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
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
    let t2 = PareTask(title: "Revisar propuesta Q3", scheduledDate: Date(), priority: .high)
    t2.scheduledTime = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date())
    let t3 = PareTask(title: "Responder emails pendientes", scheduledDate: Date(), priority: .medium)
    let t4 = PareTask(title: "Leer 20 páginas", scheduledDate: Date(), priority: .low)
    t4.isCompleted = true
    [t1, t2, t3, t4].forEach { ctx.insert($0) }

    return ZStack {
        Color.pareBackground.ignoresSafeArea()
        VStack(spacing: 10) {
            TaskCard(task: t1)
            TaskCard(task: t2)
            TaskCard(task: t3)
            TaskCard(task: t4)
            TaskCard(task: t3, style: .compact)
        }
        .padding()
    }
    .modelContainer(container)
}
