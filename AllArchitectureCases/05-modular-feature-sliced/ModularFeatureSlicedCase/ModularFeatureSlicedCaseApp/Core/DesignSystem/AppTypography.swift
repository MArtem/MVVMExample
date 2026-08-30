import SwiftUI

/// Shared design token namespace used by SwiftUI surfaces for consistent spacing, typography, color, and shape decisions.
///
/// Keep this layer value-only; feature behavior and state do not belong in design tokens.
enum AppTypography {
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title = Font.title2.weight(.semibold)
    static let cardTitle = Font.headline.weight(.semibold)
    static let body = Font.body
    static let bodySmall = Font.subheadline
    static let caption = Font.caption.weight(.medium)
    static let button = Font.body.weight(.semibold)
}
