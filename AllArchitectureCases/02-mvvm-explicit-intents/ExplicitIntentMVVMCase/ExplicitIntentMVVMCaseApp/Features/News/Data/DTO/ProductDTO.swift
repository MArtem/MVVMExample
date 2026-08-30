import Foundation

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct ProductDTO: Decodable {
    let id: Int?
    let title: String?
    let description: String?
    let category: String?
    let brand: String?
    let rating: Double?
    let thumbnail: String?
    let images: [String]?
    let stock: Int?
    let reviews: [ProductReviewDTO]?
    let meta: ProductMetaDTO?
}

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct ProductReviewDTO: Decodable {
    let rating: Int?
    let comment: String?
    let reviewerName: String?
}

/// Transport payload owned by the data/API boundary.
///
/// Mapping responsibility: keep backend optionality, naming, and wire-format quirks here so domain and presentation models stay transport-independent.
struct ProductMetaDTO: Decodable {
    let createdAt: String?
    let updatedAt: String?
}
