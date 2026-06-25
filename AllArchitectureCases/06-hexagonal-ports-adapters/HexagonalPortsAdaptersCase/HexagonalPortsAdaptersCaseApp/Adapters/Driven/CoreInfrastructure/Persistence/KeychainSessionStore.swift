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
    private let storage: KeychainSessionStorage
    private let logger: any AppLogger
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var currentSession: AuthSession?

    init(
        service: String = Bundle.main.bundleIdentifier ?? "HexagonalPortsAdaptersCase",
        account: String = "auth-session",
        storage: KeychainSessionStorage = SystemKeychainSessionStorage(),
        logger: any AppLogger = NoOpAppLogger()
    ) {
        self.service = service
        self.account = account
        self.storage = storage
        self.logger = logger
        self.currentSession = Self.loadSession(
            service: service,
            account: account,
            decoder: decoder,
            storage: storage
        )
    }

    func save(_ session: AuthSession) {
        currentSession = session
        do {
            let data = try encoder.encode(session)
            try storage.save(data, service: service, account: account)
        } catch {
            logger.log("Failed to persist auth session in Keychain: \(error)")
        }
    }

    func clear() {
        currentSession = nil
        storage.clear(service: service, account: account)
    }

    private static func loadSession(
        service: String,
        account: String,
        decoder: JSONDecoder,
        storage: KeychainSessionStorage
    ) -> AuthSession? {
        guard let data = storage.load(service: service, account: account) else { return nil }
        return try? decoder.decode(AuthSession.self, from: data)
    }
}

protocol KeychainSessionStorage: Sendable {
    func load(service: String, account: String) -> Data?
    func save(_ data: Data, service: String, account: String) throws
    func clear(service: String, account: String)
}

struct SystemKeychainSessionStorage: KeychainSessionStorage {
    func load(service: String, account: String) -> Data? {
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
        return item as? Data
    }

    func save(_ data: Data, service: String, account: String) throws {
        let query = baseQuery(service: service, account: account)
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainSessionStorageError.unhandledStatus(updateStatus)
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainSessionStorageError.unhandledStatus(addStatus)
        }
    }

    func clear(service: String, account: String) {
        SecItemDelete(baseQuery(service: service, account: account) as CFDictionary)
    }

    private func baseQuery(service: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

private enum KeychainSessionStorageError: Error {
    case unhandledStatus(OSStatus)
}
