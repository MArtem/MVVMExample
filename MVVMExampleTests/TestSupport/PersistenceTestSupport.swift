import Foundation
import SwiftData
@testable import MVVMExample

@MainActor
func makeInMemoryModelContext() throws -> ModelContext {
    let container = try AppPersistence.makeModelContainer(inMemory: true)
    return ModelContext(container)
}

@MainActor
func fetchPendingMutations(in context: ModelContext) -> [PersistedPendingMutation] {
    let descriptor = FetchDescriptor<PersistedPendingMutation>(
        sortBy: [SortDescriptor(\PersistedPendingMutation.createdAt)]
    )
    return (try? context.fetch(descriptor)) ?? []
}

@MainActor
func fetchArticleInteractions(in context: ModelContext) -> [PersistedArticleInteraction] {
    let descriptor = FetchDescriptor<PersistedArticleInteraction>(
        sortBy: [SortDescriptor(\PersistedArticleInteraction.updatedAt)]
    )
    return (try? context.fetch(descriptor)) ?? []
}
