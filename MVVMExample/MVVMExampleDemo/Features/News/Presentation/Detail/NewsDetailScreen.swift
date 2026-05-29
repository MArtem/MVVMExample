import SwiftUI

struct NewsDetailScreen: View {
    @State private var viewModel: NewsDetailViewModel

    init(viewModel: NewsDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NewsDetailStateRenderer(
            state: viewModel.state,
            onAction: viewModel.send
        )
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.send(.appeared)
        }
    }
}
