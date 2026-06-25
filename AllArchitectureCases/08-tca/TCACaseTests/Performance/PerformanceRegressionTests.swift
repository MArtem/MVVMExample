import Foundation
import Testing
import UIKit
@testable import TCACase

@MainActor
@Suite("Performance regression guardrail tests")
struct PerformanceRegressionTests {
    @Test("Large news list state building stays within unit budget")
    func largeNewsListStateBuildingStaysWithinUnitBudget() {
        let articles = makePerformanceArticles(count: 2_000)
        let builder = NewsListViewStateBuilder()

        let elapsed = measureSeconds {
            let content = builder.makeContent(from: articles)
            #expect(content.cards.count == 2_000)
        }

        #expect(elapsed < 1.0, "Expected 2,000 card states under 1.0s, got \(elapsed)s")
    }

    @Test("Article interaction merge stays within unit budget")
    func articleInteractionMergeStaysWithinUnitBudget() {
        let store = ArticleInteractionStore()
        let articles = makePerformanceArticles(count: 2_000)
        for id in stride(from: 0, to: 2_000, by: 10) {
            store.setLikeState(articleID: id, isLiked: true, likesCount: id + 10)
        }

        let elapsed = measureSeconds {
            let merged = store.merge(articles)
            #expect(merged.count == 2_000)
            #expect(merged[10].isLiked == true)
            #expect(merged[10].likesCount == 20)
        }

        #expect(elapsed < 0.5, "Expected 2,000 article merge under 0.5s, got \(elapsed)s")
    }

    @Test("Image memory cache insert and lookup stays within unit budget")
    func imageMemoryCacheInsertAndLookupStaysWithinUnitBudget() throws {
        let cache = ImageMemoryCache(countLimit: 2_000, totalCostLimit: 64 * 1024 * 1024)
        let image = try #require(makePerformanceImage())

        let elapsed = measureSeconds {
            for index in 0..<1_000 {
                cache.insert(image, forKey: "image-\(index)")
            }
            for index in 0..<1_000 {
                #expect(cache.image(forKey: "image-\(index)") != nil)
            }
        }

        #expect(elapsed < 0.5, "Expected 1,000 cache inserts/lookups under 0.5s, got \(elapsed)s")
    }
}

private func measureSeconds(_ operation: () -> Void) -> TimeInterval {
    let start = Date()
    operation()
    return Date().timeIntervalSince(start)
}

private func makePerformanceArticles(count: Int) -> [NewsArticle] {
    (0..<count).map { id in
        NewsArticle(
            id: id,
            title: "Article \(id)",
            excerpt: "Excerpt \(id)",
            source: "Source",
            category: "general",
            rating: 4.5,
            thumbnailURL: nil,
            imageURLs: [],
            publishedAt: nil,
            likesCount: id,
            commentsCount: id * 2,
            isLiked: false
        )
    }
}

private func makePerformanceImage() -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16))
    return renderer.image { context in
        UIColor.systemBlue.setFill()
        context.fill(CGRect(origin: .zero, size: CGSize(width: 16, height: 16)))
    }
}
