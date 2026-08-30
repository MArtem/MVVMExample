import SwiftUI

/// Shared design token namespace used by SwiftUI surfaces for consistent spacing, typography, color, and shape decisions.
///
/// Keep this layer value-only; feature behavior and state do not belong in design tokens.
enum AppTheme {
    static let backgroundBase = Color("AppBackground")
    static let surfacePrimary = Color("AppSurfacePrimary")
    static let surfaceSecondary = Color("AppSurfaceSecondary")
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(.tertiaryLabel)
    static let actionPrimary = Color.accentColor
    static let divider = Color("AppDivider")
    static let destructive = Color("AppDestructive")
}
