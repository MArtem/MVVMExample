import Foundation

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

struct ProductReviewDTO: Decodable {
    let rating: Int?
    let comment: String?
    let reviewerName: String?
}

struct ProductMetaDTO: Decodable {
    let createdAt: String?
    let updatedAt: String?
}
