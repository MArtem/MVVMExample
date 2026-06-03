import CoreGraphics
import Testing
@testable import AppImageLoading

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Suite("Image memory cache tests")
struct ImageMemoryCacheTests {
    @Test("Cache key includes URL and target pixel size")
    func cacheKeyIncludesURLAndTargetPixelSize() throws {
        let url = try #require(URL(string: "https://images.example.com/a.png"))

        let key = RemoteImagePipeline.cacheKey(
            url: url,
            targetSize: CGSize(width: 100, height: 50),
            scale: 2
        )

        #expect(key == "https://images.example.com/a.png|200x100")
    }

    @Test("Memory cache stores and returns exact keys")
    func memoryCacheStoresAndReturnsExactKeys() {
        let cache = ImageMemoryCache(countLimit: 2, totalCostLimit: 1024 * 1024)
        let image = makeTestImage()

        cache.insert(image, forKey: "image-key")

        #expect(cache.image(forKey: "image-key") != nil)
        #expect(cache.image(forKey: "other-key") == nil)
    }
}

private func makeTestImage() -> AppPlatformImage {
    #if canImport(UIKit)
    return UIImage(systemName: "photo") ?? UIImage()
    #else
    return NSImage(size: NSSize(width: 1, height: 1))
    #endif
}
