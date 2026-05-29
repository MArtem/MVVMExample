import SwiftUI

struct NewsListScreen: View {
    @State private var viewModel: NewsListViewModel

    init(viewModel: NewsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NewsListStateRenderer(
            state: viewModel.state,
            onAction: viewModel.send
        )
        .navigationTitle("News")
        .background(AppTheme.backgroundBase)
        .task {
            viewModel.send(.appeared)
        }
    }
}

#Preview {
    NavigationStack {
        NewsListScreen(
            viewModel: NewsListViewModel(
                repository: MockNewsRepository(),
                router: NewsRouter()
            )
        )
    }
}
