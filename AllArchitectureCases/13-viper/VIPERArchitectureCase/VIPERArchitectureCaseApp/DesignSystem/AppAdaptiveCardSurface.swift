import SwiftUI

/// Shared design token namespace used by SwiftUI surfaces for consistent spacing, typography, color, and shape decisions.
///
/// Keep this layer value-only; feature behavior and state do not belong in design tokens.
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
