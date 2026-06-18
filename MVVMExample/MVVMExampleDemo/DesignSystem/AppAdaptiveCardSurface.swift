import SwiftUI

struct AppAdaptiveCardSurface: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content.appGlassChrome(
            in: shape,
            glassTint: AppTheme.surfacePrimary,
            fallbackBackground: AppTheme.surfacePrimary
        )
    }
}

extension View {
    func appAdaptiveCardSurface(cornerRadius: CGFloat = AppRadius.card) -> some View {
        modifier(AppAdaptiveCardSurface(cornerRadius: cornerRadius))
    }
}
