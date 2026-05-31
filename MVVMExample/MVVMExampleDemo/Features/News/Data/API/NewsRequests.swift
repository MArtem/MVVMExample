import Foundation
import AppNetworking

struct ProductsListRequest: APIRequest {
    let limit: Int
    let skip: Int

    let path = "/products"
    let method: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
    }
}

struct ProductDetailRequest: APIRequest {
    let id: Int
    var path: String { "/products/\(id)" }
    let method: HTTPMethod = .get
}

struct UpdateProductLikeRequest: APIRequest {
    let id: Int
    let isLiked: Bool

    var path: String { "/products/\(id)" }
    let method: HTTPMethod = .patch

    func makeBody() throws -> Data? {
        try JSONBodyEncoder.encode(["isLiked": isLiked])
    }
}
