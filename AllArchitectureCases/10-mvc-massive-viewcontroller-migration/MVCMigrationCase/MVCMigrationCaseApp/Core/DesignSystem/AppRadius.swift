import Foundation

/// Shared design token namespace used by SwiftUI surfaces for consistent spacing, typography, color, and shape decisions.
///
/// Keep this layer value-only; feature behavior and state do not belong in design tokens.
enum AppRadius {
    static let card: CGFloat = 16
    static let field: CGFloat = 12
    static let button: CGFloat = 12
    static let avatar: CGFloat = 999
}
