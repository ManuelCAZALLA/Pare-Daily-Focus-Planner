// IdeaPostItCard.swift
import SwiftUI
import SwiftData

struct IdeaPostItCard: View {
    let idea: TramiteIdea
    let onEdit: () -> Void
    let onTogglePin: () -> Void
    let onConvertToTask: () -> Void
    let onDelete: () -> Void

    private var color: Color { Color.ideaCategory(idea.category) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ── Cinta / chincheta ──────────────────────────────────────────
            HStack {
                if idea.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "#1C1C1E"))
                        .rotationEffect(.degrees(0))
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.45))
                        .frame(width: 54, height: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                        .offset(y: -5)
                }
                Spacer()
            }

            Text(idea.text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#1C1C1E"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 2)

            // ── Pie: categoría ────────────────────────────────────────────
            HStack(spacing: 5) {
                Image(systemName: idea.category.systemImage)
                    .font(.system(size: 9, weight: .bold))
                Text(idea.category.label)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(Color(hex: "#1C1C1E").opacity(0.7))
        }
        .padding(14)
        .frame(minHeight: 96, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: color.opacity(0.22), radius: 8, y: 4)
        .rotationEffect(rotation)
        .overlay(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Color(hex: "#1C1C1E"))
                .frame(width: 18, height: 18)
                .overlay {
                    Triangle().fill(color)
                }
                .offset(x: 1, y: 1)
                .accessibilityHidden(true)
        }
        .contentShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .onTapGesture { onEdit() }
        .contextMenu {
            Button {
                onTogglePin()
            } label: {
                Label(
                    idea.isPinned ? String(localized: "ideas.unpin") : String(localized: "ideas.pin"),
                    systemImage: "pin"
                )
            }

            Button {
                onConvertToTask()
            } label: {
                Label(String(localized: "ideas.convertToTask"), systemImage: "calendar.badge.plus")
            }

            Button {
                onEdit()
            } label: {
                Label(String(localized: "general.edit"), systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(String(localized: "general.delete"), systemImage: "trash")
            }
        }
        .accessibilityLabel(idea.text)
        .accessibilityHint(String(localized: "ideas.actionsHint"))
    }

    private var rotation: Angle {
        // Rotación sutil determinista para que el muro se sienta orgánico
        let seed = abs(idea.id.hashValue) % 7 - 3
        return Angle(degrees: Double(seed))
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    let context = TramiteModelContainer.preview.mainContext
    let idea = TramiteIdea(text: "Cambiar la cerradura del trastero", category: .casa)
    context.insert(idea)

    return ScrollView {
        HStack(alignment: .top, spacing: 12) {
            IdeaPostItCard(idea: idea, onEdit: {}, onTogglePin: {}, onConvertToTask: {}, onDelete: {})
                .frame(width: 150)
            IdeaPostItCard(
                idea: {
                    let i = TramiteIdea(text: "Renovar el DNI", category: .tramite)
                    i.isPinned = true
                    context.insert(i)
                    return i
                }(),
                onEdit: {}, onTogglePin: {}, onConvertToTask: {}, onDelete: {}
            )
            .frame(width: 150)
        }
        .padding()
    }
    .background(Color(hex: "#3B2F1E"))
    .modelContainer(TramiteModelContainer.preview)
}