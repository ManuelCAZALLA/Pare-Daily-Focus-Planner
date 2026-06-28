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
        HStack(alignment: .top, spacing: 12) {

            // Icono
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.priorityBackground(task.priority))
                    .frame(width: 40, height: 40)

                Image(systemName: task.priority.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.priority(task.priority))
            }

            // Contenido
            VStack(alignment: .leading, spacing: 3) {
                // Meta (hora + prioridad)
                HStack(spacing: 6) {
                    if let time = task.scheduledTime {
                        Text(time.formatted(.dateTime.hour().minute()))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.pareGreen)
                    }

                    Text("·")
                        .foregroundStyle(Color.pareTextTertiary)
                        .font(.caption)

                    Text(task.priority.label)
                        .font(.caption)
                        .foregroundStyle(Color.pareTextSecondary)
                }

                // Título
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        task.isCompleted
                        ? Color.pareTextTertiary
                        : Color.pareTextPrimary
                    )
                    .strikethrough(task.isCompleted, color: Color.pareTextTertiary)
                    .lineLimit(2)

                // Notas
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(Color.pareTextSecondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 0)

            // Check button
            CheckCircle(isCompleted: task.isCompleted, priority: task.priority)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.pareCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.pareCardBorder, lineWidth: 0.5)
                )
        )
        .overlay(alignment: .leading) {
            // Barra de prioridad izquierda
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.priority(task.priority))
                .frame(width: 3)
                .padding(.vertical, 10)
        }
        .opacity(task.isCompleted ? 0.55 : 1)
    }

    // MARK: - Compact card

    private var compactCard: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.priority(task.priority).opacity(0.2))
                .frame(width: 8, height: 8)

            Text(task.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    task.isCompleted
                    ? Color.pareTextTertiary
                    : Color.pareTextPrimary
                )
                .strikethrough(task.isCompleted)
                .lineLimit(1)

            Spacer()

            if let time = task.scheduledTime {
                Text(time.formatted(.dateTime.hour().minute()))
                    .font(.caption)
                    .foregroundStyle(Color.pareTextSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pareCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.pareCardBorder, lineWidth: 0.5)
                )
        )
    }
}

// MARK: - CheckCircle

struct CheckCircle: View {
    let isCompleted: Bool
    let priority: Priority

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isCompleted ? Color.pareGreen : Color.pareCardBorder,
                    lineWidth: 2
                )
                .frame(width: 26, height: 26)

            if isCompleted {
                Circle()
                    .fill(Color.pareGreen)
                    .frame(width: 26, height: 26)

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .animation(.spring(duration: 0.25), value: isCompleted)
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
