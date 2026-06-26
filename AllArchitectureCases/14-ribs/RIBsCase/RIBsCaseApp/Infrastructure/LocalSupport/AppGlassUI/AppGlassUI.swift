import SwiftUI

/// Availability-gated wrapper that groups related glass-backed views when the runtime supports native Liquid Glass.
///
/// Responsibilities:
/// - use native `GlassEffectContainer` on iOS versions that provide it;
/// - preserve the original view hierarchy on older OS versions and non-iOS platforms;
/// - keep app-specific color/token decisions outside this helper.
///
/// Ownership:
/// Created directly by SwiftUI composition where related glass chrome elements should share a visual group.
struct AppGlassContainer<Content: View>: View {
    private let spacing: CGFloat?
    private let content: () -> Content

    /// Creates a glass container that falls back to a plain view hierarchy where native Liquid Glass is unavailable.
    init(
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    /// Builds either native grouped glass chrome or the unchanged host content tree.
    var body: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            content()
        }
        #else
        content()
        #endif
    }
}

/// Platform-neutral style input for glass-backed chrome surfaces.
///
/// LocalSupport owns availability/fallback mechanics. App design-system code owns semantic token resolution and passes concrete colors.
struct AppGlassChromeStyle: Sendable {
    let glassTint: Color?
    let glassStroke: Color?
    let fallbackBackground: Color
    let fallbackShadowColor: Color
    let fallbackShadowRadius: CGFloat
    let fallbackShadowX: CGFloat
    let fallbackShadowY: CGFloat
    let interactive: Bool

    /// Creates a chrome style for one host-owned visual role.
    init(
        glassTint: Color? = nil,
        glassStroke: Color? = nil,
        fallbackBackground: Color,
        fallbackShadowColor: Color = .clear,
        fallbackShadowRadius: CGFloat = 0,
        fallbackShadowX: CGFloat = 0,
        fallbackShadowY: CGFloat = 0,
        interactive: Bool = false
    ) {
        self.glassTint = glassTint
        self.glassStroke = glassStroke
        self.fallbackBackground = fallbackBackground
        self.fallbackShadowColor = fallbackShadowColor
        self.fallbackShadowRadius = fallbackShadowRadius
        self.fallbackShadowX = fallbackShadowX
        self.fallbackShadowY = fallbackShadowY
        self.interactive = interactive
    }
}

/// Availability-gated custom chrome styling that uses native Liquid Glass on supported iOS versions.
private struct AppGlassChromeModifier<ChromeShape: Shape>: ViewModifier {
    let shape: ChromeShape
    let style: AppGlassChromeStyle

    /// Applies either native glass chrome or the configured fallback surface.
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .background {
                    if let glassTint = style.glassTint {
                        shape.fill(glassTint.opacity(style.interactive ? 0.26 : 0.14))
                    }
                }
                .glassEffect(
                    style.interactive ? .regular.interactive() : .regular,
                    in: shape
                )
                .overlay {
                    let resolvedStroke = style.glassStroke ?? style.glassTint
                    if let resolvedStroke {
                        shape.stroke(resolvedStroke.opacity(style.interactive ? 0.28 : 0.18), lineWidth: 0.8)
                    }
                }
        } else {
            fallback(content: content)
        }
        #else
        fallback(content: content)
        #endif
    }

    private func fallback(content: Content) -> some View {
        content
            .background(style.fallbackBackground)
            .clipShape(shape)
            .shadow(
                color: style.fallbackShadowColor,
                radius: style.fallbackShadowRadius,
                x: style.fallbackShadowX,
                y: style.fallbackShadowY
            )
    }
}

extension View {
    /// Styles a chrome surface with native Liquid Glass on supported iOS versions and a caller-supplied fallback elsewhere.
    ///
    /// External usage:
    /// Host apps call this from SwiftUI composition after resolving app-specific semantic colors/tokens.
    func appGlassChrome<ChromeShape: Shape>(
        in shape: ChromeShape,
        style: AppGlassChromeStyle
    ) -> some View {
        modifier(AppGlassChromeModifier(shape: shape, style: style))
    }

    /// Convenience overload for callers that do not need to construct a reusable style value.
    func appGlassChrome<ChromeShape: Shape>(
        in shape: ChromeShape,
        glassTint: Color? = nil,
        glassStroke: Color? = nil,
        fallbackBackground: Color,
        fallbackShadowColor: Color = .clear,
        fallbackShadowRadius: CGFloat = 0,
        fallbackShadowX: CGFloat = 0,
        fallbackShadowY: CGFloat = 0,
        interactive: Bool = false
    ) -> some View {
        appGlassChrome(
            in: shape,
            style: AppGlassChromeStyle(
                glassTint: glassTint,
                glassStroke: glassStroke,
                fallbackBackground: fallbackBackground,
                fallbackShadowColor: fallbackShadowColor,
                fallbackShadowRadius: fallbackShadowRadius,
                fallbackShadowX: fallbackShadowX,
                fallbackShadowY: fallbackShadowY,
                interactive: interactive
            )
        )
    }
}
