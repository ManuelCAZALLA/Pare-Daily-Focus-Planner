// Color+Pare.swift
import SwiftUI

extension Color {
    static let pareGreen      = Color(red: 0.23, green: 0.72, blue: 0.37)
    static let pareGreenDark  = Color(red: 0.10, green: 0.48, blue: 0.21)
    static let pareBackground = Color(.systemGroupedBackground)
    static let pareCard       = Color(.secondarySystemGroupedBackground)

    static func priority(_ p: Priority) -> Color {
        switch p {
        case .low:    return .gray
        case .medium: return .blue
        case .high:   return .orange
        case .must:   return .red
        }
    }
}
