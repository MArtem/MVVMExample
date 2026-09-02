import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Bounded in-memory image cache for already-downsampled UI images.
///
/// Concurrency:
/// This actor exclusively owns the mutable cache and its memory-warning task.
///
/// Invariant:
/// Store images after downsampling to the intended render size, not original remote dimensions.
actor ImageMemoryCache {
    static let shared = ImageMemoryCache()

    private let cache = NSCache<NSString, AppPlatformImage>()

    #if canImport(UIKit)
    private var memoryWarningTask: Task<Void, Never>?
    #endif

    init(countLimit: Int = 200, totalCostLimit: Int = 48 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit

        #if canImport(UIKit)
        Task { [weak self] in
            await self?.startObservingMemoryWarnings()
        }
        #endif
    }

    #if canImport(UIKit)
    private func startObservingMemoryWarnings() {
        guard memoryWarningTask == nil else { return }
        memoryWarningTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didReceiveMemoryWarningNotification) {
                guard let self else { return }
                await self.removeAll()
            }
        }
    }
    #endif

    deinit {
        #if canImport(UIKit)
        memoryWarningTask?.cancel()
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
