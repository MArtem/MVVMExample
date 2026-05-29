import Foundation

protocol APIClient {
    func send<Response: Decodable>(_ request: APIRequest) async throws -> Response
}
