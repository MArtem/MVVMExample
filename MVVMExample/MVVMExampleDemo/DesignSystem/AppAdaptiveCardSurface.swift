import SwiftUI

struct AppAdaptiveCardSurface: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(AppTheme.surfacePrimary.opacity(0.55), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    func appAdaptiveCardSurface(cornerRadius: CGFloat = AppRadius.card) -> some View {
        modifier(AppAdaptiveCardSurface(cornerRadius: cornerRadius))
    }
}
