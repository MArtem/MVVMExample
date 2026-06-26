import Foundation
import ImageIO

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Remote image loader that fetches, downsamples, and caches images for SwiftUI surfaces.
///
/// Responsibilities:
/// - keep network and decode work outside `body` evaluation;
/// - cache by URL and target pixel size;
/// - downsample before publishing images to UI.
///
/// Errors:
/// Throws `RemoteImagePipelineError.invalidResponse` for non-2xx responses and `RemoteImagePipelineError.decodingFailed` for invalid image data.
enum RemoteImagePipelineError: LocalizedError, Equatable, Sendable {
    case invalidResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid image response."
        case .decodingFailed:
            return "Image decoding failed."
        }
    }
}

struct RemoteImagePipeline: Sendable {
    static let shared = RemoteImagePipeline()

    private let session: URLSession
    private let cache: ImageMemoryCache

    init(
        session: URLSession = URLSession(configuration: Self.defaultSessionConfiguration()),
        cache: ImageMemoryCache = .shared
    ) {
        self.session = session
        self.cache = cache
    }

    /// Creates the default image session policy.
    ///
    /// The pipeline uses bounded memory/disk URL cache behavior instead of relying on
    /// `URLSession.shared`, which makes cache ownership explicit for feed images.
    static func defaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 16 * 1024 * 1024,
            diskCapacity: 96 * 1024 * 1024,
            diskPath: "MVPPassiveViewCaseRemoteImageURLCache"
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return configuration
    }

    /// Loads an image for a concrete render size.
    ///
    /// External usage:
    /// Called by app-local remote image views or feature-specific image prefetchers.
    ///
    /// Concurrency:
    /// Cancellation before decode/cache insert stops the load and avoids publishing stale work.
    func image(from url: URL, targetSize: CGSize, scale: CGFloat) async throws -> AppPlatformImage {
        let cacheKey = Self.cacheKey(url: url, targetSize: targetSize, scale: scale)
        if let cached = cache.image(forKey: cacheKey) {
            return cached
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw RemoteImagePipelineError.invalidResponse
        }
        try Task.checkCancellation()

        guard let image = Self.downsample(data: data, targetSize: targetSize, scale: scale) else {
            throw RemoteImagePipelineError.decodingFailed
        }
        cache.insert(image, forKey: cacheKey)
        return image
    }

    static func cacheKey(url: URL, targetSize: CGSize, scale: CGFloat) -> String {
        "\(url.absoluteString)|\(Int(targetSize.width * scale))x\(Int(targetSize.height * scale))"
    }

    private static func downsample(data: Data, targetSize: CGSize, scale: CGFloat) -> AppPlatformImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }

        let maxDimension = max(targetSize.width, targetSize.height) * scale
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, Int(maxDimension))
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return nil
        }

        #if canImport(UIKit)
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        #else
        let pointSize = CGSize(
            width: CGFloat(cgImage.width) / max(scale, 1),
            height: CGFloat(cgImage.height) / max(scale, 1)
        )
        return AppPlatformImage(cgImage: cgImage, size: pointSize)
        #endif
    }
}
