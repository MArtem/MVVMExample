import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct ProductsResponseDTO: Decodable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
