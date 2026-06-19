import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// SwiftUI image view backed by `RemoteImagePipeline`.
///
/// Behavior:
/// The view keeps a stable placeholder frame, starts loading through `.task(id:)`, and lets SwiftUI cancel work when the row/detail view disappears or changes identity.
///
/// Important:
/// This view owns only transient UI image state; it does not own global cache policy beyond the injected pipeline.
struct CachedRemoteImageView<Placeholder: View, Failure: View>: View {
    private let url: URL?
    private let targetSize: CGSize
    private let contentMode: ContentMode
    private let pipeline: RemoteImagePipeline
    private let placeholder: () -> Placeholder
    private let failure: () -> Failure

    @Environment(\.displayScale) private var displayScale
    @State private var image: AppPlatformImage?
    @State private var didFail = false

    init(
        url: URL?,
        targetSize: CGSize,
        contentMode: ContentMode = .fill,
        pipeline: RemoteImagePipeline = .shared,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.url = url
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.pipeline = pipeline
        self.placeholder = placeholder
        self.failure = failure
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: targetSize.height)
            .clipped()
            .task(id: taskID) {
                await load()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            #if canImport(UIKit)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
            #else
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
            #endif
        } else if didFail {
            failure()
        } else {
            placeholder()
        }
    }

    private var taskID: String {
        guard let url else { return "nil" }
        return RemoteImagePipeline.cacheKey(url: url, targetSize: targetSize, scale: displayScale)
    }

    @MainActor
    private func load() async {
        guard let url else {
            image = nil
            didFail = true
            return
        }

        image = nil
        didFail = false
        do {
            let loaded = try await pipeline.image(
                from: url,
                targetSize: targetSize,
                scale: displayScale
            )
            try Task.checkCancellation()
            image = loaded
        } catch is CancellationError {
            return
        } catch {
            didFail = true
        }
    }
}
