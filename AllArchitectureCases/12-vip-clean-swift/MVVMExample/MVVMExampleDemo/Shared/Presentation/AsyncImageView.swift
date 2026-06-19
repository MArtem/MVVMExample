import SwiftUI

/// App-level wrapper around the LocalSupport cached image loader.
///
/// Responsibilities:
/// - applies app design-system placeholder/failure UI;
/// - keeps caller API small for feature views;
/// - delegates loading, caching, downsampling, and cancellation to LocalSupport image primitives.
struct AsyncImageView: View {
    let url: URL?
    let width: CGFloat?
    let height: CGFloat

    init(url: URL?, width: CGFloat? = nil, height: CGFloat) {
        self.url = url
        self.width = width
        self.height = height
    }

    var body: some View {
        CachedRemoteImageView(
            url: url,
            targetSize: CGSize(width: width ?? 800, height: height)
        ) {
            Rectangle()
                .fill(AppTheme.surfaceSecondary)
                .overlay(ProgressView())
        } failure: {
            Rectangle()
                .fill(AppTheme.surfaceSecondary)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(AppTheme.textTertiary)
                }
        }
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .frame(height: height)
    }
}
