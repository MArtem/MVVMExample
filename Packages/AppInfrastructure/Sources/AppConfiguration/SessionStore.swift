import Foundation

/// Stores the current authenticated session for the active app runtime.
///
/// Concurrency:
/// Main-actor isolated because current app session changes drive SwiftUI navigation state.
@MainActor
public protocol SessionStore<Session>: AnyObject {
    associatedtype Session
    var currentSession: Session? { get }
    func save(_ session: Session)
    func clear()
}

/// Demo/runtime session store with no persistence.
///
/// Ownership:
/// Created by the app dependency container and shared by app-level coordination.
///
/// Important:
/// This store intentionally does not survive relaunch; production persistence requires a separate approved policy.
@MainActor
public final class InMemorySessionStore<Session>: SessionStore {
    public private(set) var currentSession: Session?

    public init(initialSession: Session? = nil) {
        self.currentSession = initialSession
    }

    public func save(_ session: Session) {
        currentSession = session
    }

    public func clear() {
        currentSession = nil
    }
}
