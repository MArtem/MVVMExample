import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Bounded in-memory image cache for already-downsampled UI images.
///
/// Thread safety:
/// `NSCache` is thread-safe for concurrent access. The class is marked `@unchecked Sendable` to expose that runtime guarantee to Swift concurrency.
///
/// Invariant:
/// Store images after downsampling to the intended render size, not original remote dimensions.
final class ImageMemoryCache: @unchecked Sendable {
    static let shared = ImageMemoryCache()

    private let cache = NSCache<NSString, AppPlatformImage>()

    #if canImport(UIKit)
    private var memoryWarningObserver: NSObjectProtocol?
    #endif

    init(countLimit: Int = 200, totalCostLimit: Int = 48 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit

        #if canImport(UIKit)
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.removeAll()
        }
        #endif
    }

    deinit {
        #if canImport(UIKit)
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
        #endif
    }

    func image(forKey key: String) -> AppPlatformImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: AppPlatformImage, forKey key: String) {
        let cost = Self.estimatedCost(for: image)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func removeAll() {
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
