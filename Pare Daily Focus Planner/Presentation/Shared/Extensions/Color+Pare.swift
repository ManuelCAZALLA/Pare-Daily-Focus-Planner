// Color+Pare.swift
import SwiftUI

extension Color {

    // MARK: - Brand
    static let pareGreen     = Color(hex: "#22C55E")
    static let pareGreenDark = Color(hex: "#15803D")

    // MARK: - Dark backgrounds
    static let pareBackground     = Color(hex: "#0C0C0E")  // fondo principal
    static let pareCard           = Color(hex: "#1A1A1C")  // card background
    static let pareCardBorder     = Color(hex: "#2A2A2C")  // card border
    static let pareSeparator      = Color(hex: "#222224")  // separadores
    static let pareTimelineLine   = Color(hex: "#2A2A2C")  // línea timeline
    static let pareSecondaryBg    = Color(hex: "#161618")  // tabbar / sheet

    // MARK: - Text
    static let pareTextPrimary    = Color.white
    static let pareTextSecondary  = Color(hex: "#8E8E93")
    static let pareTextTertiary   = Color(hex: "#48484A")

    // MARK: - Priority
    static func priority(_ p: Priority) -> Color {
        switch p {
        case .low:    return Color(hex: "#8E8E93")
        case .medium: return Color(hex: "#007AFF")
        case .high:   return Color(hex: "#FF9500")
        case .must:   return Color(hex: "#FF3B30")
        }
    }

    static func priorityBackground(_ p: Priority) -> Color {
        priority(p).opacity(0.12)
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
