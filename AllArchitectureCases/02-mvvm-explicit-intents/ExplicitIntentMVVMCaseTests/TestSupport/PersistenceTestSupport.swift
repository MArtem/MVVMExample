import Foundation
import SwiftData
@testable import ExplicitIntentMVVMCase

@MainActor
func makeInMemoryModelContainer() throws -> ModelContainer {
    try AppPersistence.makeModelContainer(inMemory: true)
}

@MainActor
func makeInMemoryModelContext() throws -> ModelContext {
    let container = try makeInMemoryModelContainer()
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

@MainActor
func fetchUserProfiles(in context: ModelContext) -> [PersistedUserProfile] {
    let descriptor = FetchDescriptor<PersistedUserProfile>(
        sortBy: [SortDescriptor(\PersistedUserProfile.updatedAt)]
    )
    return (try? context.fetch(descriptor)) ?? []
}
