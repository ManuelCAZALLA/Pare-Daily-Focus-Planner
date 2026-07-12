import SwiftUI
import WidgetKit

struct PareWidgetView: View {
    let entry: PareWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if let task = entry.task {
                Spacer(minLength: 0)
                Text(task.title)
                    .font(.headline.weight(.bold))
                    .lineLimit(2)
                    .foregroundStyle(.white)

                if let time = task.time {
                    Label(time, systemImage: "clock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.pareGreen)
                }
            } else {
                Spacer(minLength: 0)
                Text("Todo listo")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text("Añade una tarea para empezar.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(2)
            }

            progress
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(hex: "#1A1B20"), Color(hex: "#0C0C0E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                header
                Text(entry.task?.title ?? "No tienes tareas pendientes")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let time = entry.task?.time {
                    Label(time, systemImage: "clock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.pareGreen)
                } else {
                    Text("Disfruta de tu tiempo libre.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer(minLength: 0)
                progress
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(Color.pareGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(entry.completedCount)/\(entry.totalCount)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 78, height: 78)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(hex: "#1A1B20"), Color(hex: "#0C0C0E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.pareGreen)
            Text("PARE")
                .font(.caption.weight(.heavy))
                .kerning(1)
                .foregroundStyle(.white)
            Spacer()
            Text("HOY")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    private var progress: some View {
        ProgressView(value: progressValue)
            .tint(Color.pareGreen)
    }

    private var progressValue: Double {
        guard entry.totalCount > 0 else { return 0 }
        return Double(entry.completedCount) / Double(entry.totalCount)
    }
}
