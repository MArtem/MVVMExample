import Foundation

/// Enum contract for a local app boundary.
///
/// Document ownership and side effects here when this type grows beyond value-only data.
enum AppTab: Hashable {
    case news
    case profile
}
