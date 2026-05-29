import Foundation

struct ProductsListRequest: APIRequest {
    let path = "/products"
    let method: HTTPMethod = .get

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "skip", value: "0")
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

    var body: Data? {
        JSONBodyEncoder.encode(["isLiked": isLiked])
    }
}
