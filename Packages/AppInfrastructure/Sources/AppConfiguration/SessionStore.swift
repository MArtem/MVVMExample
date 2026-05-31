import Foundation

@MainActor
public protocol SessionStore<Session>: AnyObject {
    associatedtype Session
    var currentSession: Session? { get }
    func save(_ session: Session)
    func clear()
}

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
