import Foundation

/// Products list endpoint request used as the backing API for news cards.
///
/// Pagination contract:
/// `limit` and `skip` must mirror `NewsPageRequest` so Presenters can apply backpressure without knowing transport details.
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

/// API request description for the network adapter layer.
///
/// Boundary rule: encode transport path, method, headers, and body here; callers should pass domain intent, not URLSession details.
struct ProductDetailRequest: APIRequest {
    let id: Int
    var path: String { "/products/\(id)" }
    let method: HTTPMethod = .get
}

/// Demo API mutation for like/favorite state.
///
/// Important:
/// Real production APIs should define this contract server-side; this request only adapts the current demo backend shape.
struct UpdateProductLikeRequest: APIRequest {
    let id: Int
    let isLiked: Bool

    var path: String { "/products/\(id)" }
    let method: HTTPMethod = .patch

    func makeBody() throws -> Data? {
        try JSONBodyEncoder.encode(["isLiked": isLiked])
    }
}
