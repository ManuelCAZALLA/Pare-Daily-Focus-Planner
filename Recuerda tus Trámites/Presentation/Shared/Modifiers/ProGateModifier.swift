import SwiftUI
import RevenueCatUI

struct ProGateModifier: ViewModifier {
    @Environment(PurchasesService.self) private var purchases

    let isProFeature: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if isProFeature && !purchases.isProActive {
                    purchases.showPaywall = true
                } else {
                    action()
                }
            }
    }
}

extension View {
    func proGated(isProFeature: Bool = true, action: @escaping () -> Void) -> some View {
        modifier(ProGateModifier(isProFeature: isProFeature, action: action))
    }
}
