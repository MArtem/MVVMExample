import AppErrors
import Foundation

public enum AppErrorMapper {
    public static func userMessage(for error: Error) -> String {
        guard let apiError = error as? AppAPIError else {
            return AppStrings.text("Something went wrong. Please try again.")
        }

        switch apiError {
        case .offline:
            return AppStrings.text("You appear to be offline. Check your connection and try again.")
        case .timeout:
            return AppStrings.text("The request took too long. Please try again.")
        case .cancelled:
            return AppStrings.text("The request was cancelled.")
        case .unauthorized:
            return AppStrings.text("Your session expired. Please sign in again.")
        case .forbidden:
            return AppStrings.text("You don’t have permission to perform this action.")
        case .server:
            return AppStrings.text("The server could not complete the request. Please try again.")
        case .encoding, .decoding, .invalidResponse, .invalidURL:
            return AppStrings.text("We couldn’t process the server response. Please try again later.")
        case .transport:
            return AppStrings.text("The network request failed. Please try again.")
        }
    }
}
