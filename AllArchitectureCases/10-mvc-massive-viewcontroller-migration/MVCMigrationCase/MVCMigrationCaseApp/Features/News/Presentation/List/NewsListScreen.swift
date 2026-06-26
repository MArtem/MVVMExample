import SwiftUI

/// SwiftUI rendering surface for already-owned feature state.
///
/// Ownership: renders input state and forwards explicit user intents; do not start repository work or store durable state from `body`.
struct NewsListScreen: View {
    @State private var controller: NewsListController

    init(controller: NewsListController) {
        _controller = State(initialValue: controller)
    }

    var body: some View {
        NewsListStateRenderer(
            state: controller.state,
            onRetryTap: controller.retryTapped,
            onRefresh: controller.refreshRequested,
            onArticleTap: controller.articleTapped(id:),
            onLikeTap: controller.likeTapped(id:),
            onCommentsTap: controller.commentsTapped(id:),
            onItemAppear: controller.loadNextPageIfNeeded(currentItemID:),
            onRetryLoadNextPageTap: controller.retryLoadNextPageTapped
        )
        .navigationTitle(AppStrings.text("News"))
        .background(AppTheme.backgroundBase)
        .task {
            controller.appeared()
        }
        .onAppear {
            controller.becameVisible()
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            controller: NewsListController(
                repository: MockNewsRepository(),
                router: NewsRouter(),
                interactionStore: ArticleInteractionStore()
            )
        )
    }
}
