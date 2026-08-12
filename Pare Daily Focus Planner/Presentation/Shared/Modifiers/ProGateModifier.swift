import SwiftUI
import RevenueCatUI

struct ProGateModifier: ViewModifier {
    @Environment(PurchasesService.self) private var purchases
    @State private var showPaywall = false

    let isProFeature: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if isProFeature && !purchases.isProActive {
                    showPaywall = true
                } else {
                    action()
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .preferredColorScheme(.dark)
            }
    }
}

extension View {
    func proGated(isProFeature: Bool = true, action: @escaping () -> Void) -> some View {
        modifier(ProGateModifier(isProFeature: isProFeature, action: action))
    }
}
