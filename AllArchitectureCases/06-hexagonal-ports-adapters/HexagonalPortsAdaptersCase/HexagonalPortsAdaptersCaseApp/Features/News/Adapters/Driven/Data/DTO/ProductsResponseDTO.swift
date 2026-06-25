import Foundation

struct ProductsResponseDTO: Decodable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
