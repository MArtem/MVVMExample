import SwiftUI

struct ArticleDetailView: View {
    let article: ArticleEntity

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title.bold())
                Text(article.summary)
                    .font(.body)
                Text("Reading time: \(article.readingMinutes) minutes")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Detail")
        }
    }
}
