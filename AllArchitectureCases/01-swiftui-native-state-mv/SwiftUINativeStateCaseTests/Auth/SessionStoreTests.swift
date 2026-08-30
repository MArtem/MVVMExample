import Foundation
import SwiftData
import Testing
@testable import SwiftUINativeStateCase

@MainActor
@Suite("Session store tests")
struct SessionStoreTests {
    @Test("Keychain session restore clear corrupt payload and SwiftData exclusion")
    func keychainSessionRestoreClearCorruptPayloadAndSwiftDataExclusion() throws {
        let storage = InMemoryKeychainSessionStorage()
        let service = "SwiftUINativeStateCaseTests.session"
        let session = makeSessionStoreSession()
        let context = try makeInMemoryModelContext()

        let firstStore = KeychainSessionStore(service: service, storage: storage)
        firstStore.save(session)
        #expect(KeychainSessionStore(service: service, storage: storage).currentSession == session)
        #expect(fetchPendingMutations(in: context).isEmpty)
        #expect(fetchArticleInteractions(in: context).isEmpty)
        #expect(fetchUserProfiles(in: context).isEmpty)

        firstStore.clear()
        #expect(firstStore.currentSession == nil)
        #expect(KeychainSessionStore(service: service, storage: storage).currentSession == nil)

        storage.setRawData(Data("not-json".utf8), service: service, account: "auth-session")
        #expect(KeychainSessionStore(service: service, storage: storage).currentSession == nil)
    }
}

private func makeSessionStoreSession() -> AuthSession {
    AuthSession(
        accessToken: "test-access-token-not-a-secret",
        refreshToken: "test-refresh-token-not-a-secret",
        user: AppUser(
            id: 42,
            username: "ada",
            email: "ada@example.com",
            firstName: "Ada",
            lastName: "Lovelace",
            imageURL: nil
        )
    )
}

private final class InMemoryKeychainSessionStorage: KeychainSessionStorage, @unchecked Sendable {
    private var values: [String: Data] = [:]

    func load(service: String, account: String) -> Data? {
        values[key(service: service, account: account)]
    }

    func save(_ data: Data, service: String, account: String) throws {
        values[key(service: service, account: account)] = data
    }

    func clear(service: String, account: String) {
        values.removeValue(forKey: key(service: service, account: account))
    }

    func setRawData(_ data: Data, service: String, account: String) {
        values[key(service: service, account: account)] = data
    }

    private func key(service: String, account: String) -> String {
        "\(service)#\(account)"
    }
}
