import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let height: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(AppTheme.surfaceSecondary)
                    .overlay(ProgressView())

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Rectangle()
                    .fill(AppTheme.surfaceSecondary)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(AppTheme.textTertiary)
                    }

            @unknown default:
                Rectangle()
                    .fill(AppTheme.surfaceSecondary)
            }
        }
        .frame(height: height)
        .clipped()
    }
}
