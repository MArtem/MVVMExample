import AppImageLoading
import SwiftUI

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
        .frame(maxWidth: width == nil ? .infinity : width)
    }
}
