import Foundation

/// Bounded in-memory image cache for already-downsampled UI images.
///
/// Thread safety:
/// `NSCache` is thread-safe for concurrent access. The class is marked `@unchecked Sendable` to expose that runtime guarantee to Swift concurrency.
///
/// Invariant:
/// Store images after downsampling to the intended render size, not original remote dimensions.
public final class ImageMemoryCache: @unchecked Sendable {
    public static let shared = ImageMemoryCache()

    private let cache = NSCache<NSString, AppPlatformImage>()

    public init(countLimit: Int = 200, totalCostLimit: Int = 48 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }

    public func image(forKey key: String) -> AppPlatformImage? {
        cache.object(forKey: key as NSString)
    }

    public func insert(_ image: AppPlatformImage, forKey key: String) {
        let cost = Self.estimatedCost(for: image)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    public func removeAll() {
        cache.removeAllObjects()
    }

    private static func estimatedCost(for image: AppPlatformImage) -> Int {
        #if canImport(UIKit)
        let scale = image.scale
        #else
        let scale = 1.0
        #endif

        return Int(image.size.width * image.size.height * scale * scale * 4)
    }
}
