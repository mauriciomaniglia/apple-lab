import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decoding(Error)
    case networkingError(Error)
}
