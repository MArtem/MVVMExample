import Foundation
import Testing
@testable import CoordinatorFlowCase

@Suite("ViewStateBuilder deterministic formatting tests")
struct ViewStateBuilderTests {
    @Test("News list card precomputes display text labels and accessibility")
    func newsListCardPrecomputesDisplayTextLabelsAndAccessibility() throws {
        let builder = NewsListViewStateBuilder()
        let article = makeBuilderArticle(
            id: 7,
            source: "daily news",
            category: "general",
            rating: 4.25,
            likesCount: 12,
            commentsCount: 3,
            isLiked: false
        )

        let card = builder.makeCard(from: article)

        #expect(card.id == 7)
        #expect(card.sourceDisplayText == "DAILY NEWS")
        #expect(card.publishedAtText == "Recently")
        #expect(card.likesText == "12")
        #expect(card.commentsText == "Comments 3")
        #expect(card.likeState == .notLiked)
        #expect(card.likeIconName == "hand.thumbsup")
        #expect(card.accessibilityLabel == "daily news. Article 7. Recently.")
        #expect(card.likeAccessibilityLabel == "Like article")
        #expect(card.commentsAccessibilityLabel == "Comments 3")
    }

    @Test("News detail content precomputes category rating count and favorite text")
    func newsDetailContentPrecomputesCategoryRatingCountAndFavoriteText() {
        let builder = NewsDetailViewStateBuilder()
        let article = makeBuilderArticle(
            id: 8,
            source: "Wire",
            category: "general",
            rating: 4,
            likesCount: 6,
            commentsCount: 2,
            isLiked: true
        )

        let content = builder.makeContent(from: article, favoriteErrorMessage: "Saved locally")

        #expect(content.id == 8)
        #expect(content.categoryText == "General")
        #expect(content.ratingText == "Rating 4")
        #expect(content.likesText == "Likes 6")
        #expect(content.commentsText == "Comments 2")
        #expect(content.isFavorite == true)
        #expect(content.favoriteErrorMessage == "Saved locally")
    }

    @Test("Profile content precomputes display fallbacks and username")
    func profileContentPrecomputesDisplayFallbacksAndUsername() {
        let builder = ProfileViewStateBuilder()
        let profile = UserProfile(
            id: 42,
            username: "ada",
            email: "ada@example.com",
            firstName: "Ada",
            lastName: "Lovelace",
            phone: nil,
            imageURL: nil,
            companyTitle: nil
        )

        let content = builder.makeContent(from: profile)

        #expect(content.id == 42)
        #expect(content.displayName == "Ada Lovelace")
        #expect(content.usernameText == "@ada")
        #expect(content.emailText == "ada@example.com")
        #expect(content.phoneText == "No phone")
        #expect(content.companyText == "No company title")
    }
}

private func makeBuilderArticle(
    id: Int,
    source: String,
    category: String,
    rating: Double,
    likesCount: Int,
    commentsCount: Int,
    isLiked: Bool
) -> NewsArticle {
    NewsArticle(
        id: id,
        title: "Article \(id)",
        excerpt: "Excerpt \(id)",
        source: source,
        category: category,
        rating: rating,
        thumbnailURL: nil,
        imageURLs: [],
        publishedAt: nil,
        likesCount: likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked
    )
}
