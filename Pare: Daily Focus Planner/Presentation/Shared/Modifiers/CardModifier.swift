// CardModifier.swift
import SwiftUI

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 14
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.pareCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func pareCard(cornerRadius: CGFloat = 14, padding: CGFloat = 16) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Sample card content")
            .frame(maxWidth: .infinity, alignment: .leading)
            .pareCard()

        Text("Compact padding")
            .frame(maxWidth: .infinity, alignment: .leading)
            .pareCard(padding: 12)
    }
    .padding()
    .background(Color.pareBackground)
}
