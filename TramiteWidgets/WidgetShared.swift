// WidgetShared.swift
import SwiftUI

extension Color {

    // MARK: - Brand
    static let tramiteGreen = Color(hex: "#22C55E")
    static let tramiteGreenDark = Color(hex: "#15803D")

    // MARK: - Priority
    static func priority(_ p: Int) -> Color {
        switch p {
        case 3: return Color(hex: "#FF3B30")   // must
        case 2: return Color(hex: "#FF9500")   // high
        case 1: return Color(hex: "#007AFF")   // medium
        default: return Color(hex: "#8E8E93")  // low
        }
    }

    // MARK: - Urgencia de trámites
    static func urgency(_ daysRemaining: Int) -> Color {
        if daysRemaining <= 7 { return Color(hex: "#FF3B30") }   // rojo
        if daysRemaining <= 30 { return Color(hex: "#FF9500") }  // naranja
        return Color.tramiteGreen                                     // verde
    }

    // MARK: - Hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fondo compartido de widgets

struct WidgetBackground: View {
    var body: some View {
        Color(hex: "#121316")
    }
}

// MARK: - Cabecera con logo de Recuerda tus Trámites

struct TramiteWidgetHeader: View {
    var title: String = "HOY"

    var body: some View {
        HStack(spacing: 6) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            Text("RECUERDA TUS TRÁMITES")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .kerning(1.2)
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
        }
    }
}

// MARK: - Utilidades

enum WidgetFormatters {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "HH:mm",
            options: 0,
            locale: .autoupdatingCurrent
        )
        return formatter
    }()
}

// MARK: - Acceso Pro (App Group compartido con la app)

enum WidgetProAccess {
    static let appGroupID = "group.com.manuelcazalla.recuerdatustramites"

    static var isProActive: Bool {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "isProActive") ?? false
    }
}

struct WidgetProLockedView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.tramiteGreen)
            Text("pro.locked")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text("pro.widgets.locked")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProGatedWidgetContent<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if WidgetProAccess.isProActive {
            content()
        } else {
            WidgetProLockedView()
        }
    }
}
