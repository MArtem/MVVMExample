import Foundation

public enum NetworkHTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol NetworkRequest {
    var path: String { get }
    var method: NetworkHTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    func makeBody() throws -> Data?
}

public extension NetworkRequest {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    func makeBody() throws -> Data? { nil }
}

public protocol NetworkClient {
    func send<Response: Decodable>(_ request: NetworkRequest) async throws -> Response
}
