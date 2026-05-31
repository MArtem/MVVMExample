import AppErrors
import Foundation
import ImageIO
import UIKit

public struct RemoteImagePipeline: Sendable {
    public static let shared = RemoteImagePipeline()

    private let session: URLSession
    private let cache: ImageMemoryCache

    public init(
        session: URLSession = .shared,
        cache: ImageMemoryCache = .shared
    ) {
        self.session = session
        self.cache = cache
    }

    public func image(from url: URL, targetSize: CGSize, scale: CGFloat) async throws -> UIImage {
        let cacheKey = Self.cacheKey(url: url, targetSize: targetSize, scale: scale)
        if let cached = cache.image(forKey: cacheKey) {
            return cached
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AppAPIError.invalidResponse
        }
        try Task.checkCancellation()

        guard let image = Self.downsample(data: data, targetSize: targetSize, scale: scale) else {
            throw AppAPIError.decoding("Image decoding failed")
        }
        cache.insert(image, forKey: cacheKey)
        return image
    }

    public static func cacheKey(url: URL, targetSize: CGSize, scale: CGFloat) -> String {
        "\(url.absoluteString)|\(Int(targetSize.width * scale))x\(Int(targetSize.height * scale))"
    }

    private static func downsample(data: Data, targetSize: CGSize, scale: CGFloat) -> UIImage? {
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
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
