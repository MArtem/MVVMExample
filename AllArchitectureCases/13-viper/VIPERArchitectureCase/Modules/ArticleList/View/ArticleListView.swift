import SwiftUI

struct ArticleListView: View {
    @Bindable private var presenter: ArticleListPresenter
    private let router: ArticleListRouter

    init(presenter: ArticleListPresenter, router: ArticleListRouter) {
        self.presenter = presenter
        self.router = router
    }

    var body: some View {
        NavigationStack {
            Group {
                if presenter.isLoading {
                    ProgressView("Loading VIPER module")
                } else if let message = presenter.message {
                    ContentUnavailableView("VIPER", systemImage: "doc.text", description: Text(message))
                } else {
                    List(presenter.rows) { row in
                        Button {
                            presenter.articleSelected(id: row.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(row.title)
                                    .font(.headline)
                                Text(row.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .accessibilityLabel(row.accessibilityLabel)
                    }
                    .refreshable {
                        presenter.refreshRequested()
                    }
                }
            }
            .navigationTitle("VIPER Case")
            .toolbar {
                Button("Reload") {
                    presenter.refreshRequested()
                }
            }
            .sheet(item: selectedArticleBinding) { article in
                router.makeDetailView(for: article)
            }
        }
        .task {
            presenter.appeared()
        }
    }

    private var selectedArticleBinding: Binding<ArticleEntity?> {
        Binding(
            get: { presenter.selectedArticle },
            set: { newValue in
                if newValue == nil {
                    presenter.detailDismissed()
                }
            }
        )
    }
}
