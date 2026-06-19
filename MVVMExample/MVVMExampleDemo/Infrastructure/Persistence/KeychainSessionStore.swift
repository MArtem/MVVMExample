import Foundation
import Security

/// Keychain-backed session store for token-like authentication state.
///
/// Ownership:
/// Created by the app dependency container and read by `AppRootCoordinator` on launch.
///
/// Security boundary:
/// Access and refresh tokens must not be stored in SwiftData or logged. This type stores the encoded session payload in the app Keychain item for relaunch restoration.
@MainActor
final class KeychainSessionStore: SessionStore {
    private let service: String
    private let account: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var currentSession: AuthSession?

    init(
        service: String = Bundle.main.bundleIdentifier ?? "MVVMExample",
        account: String = "auth-session"
    ) {
        self.service = service
        self.account = account
        self.currentSession = Self.loadSession(
            service: service,
            account: account,
            decoder: decoder
        )
    }

    func save(_ session: AuthSession) {
        currentSession = session
        do {
            let data = try encoder.encode(session)
            try saveData(data)
        } catch {
            assertionFailure("Failed to persist auth session in Keychain: \(error)")
        }
    }

    func clear() {
        currentSession = nil
        SecItemDelete(baseQuery() as CFDictionary)
    }

    private func saveData(_ data: Data) throws {
        let query = baseQuery()
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainSessionStoreError.unhandledStatus(updateStatus)
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainSessionStoreError.unhandledStatus(addStatus)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    private static func loadSession(service: String, account: String, decoder: JSONDecoder) -> AuthSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }
        return try? decoder.decode(AuthSession.self, from: data)
    }
}

private enum KeychainSessionStoreError: Error {
    case unhandledStatus(OSStatus)
}
