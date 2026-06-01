import Foundation
import Testing
import AppErrors
@testable import AppLocalization

@Suite("App error mapper tests")
struct AppErrorMapperTests {
    @Test("Known API errors map to user-safe messages", arguments: [
        AppAPIError.offline,
        AppAPIError.timeout,
        AppAPIError.cancelled,
        AppAPIError.unauthorized("technical auth detail"),
        AppAPIError.forbidden("technical forbidden detail"),
        AppAPIError.server(statusCode: 500, message: "technical server detail"),
        AppAPIError.encoding("technical encoding detail"),
        AppAPIError.decoding("technical decoding detail"),
        AppAPIError.invalidResponse,
        AppAPIError.invalidURL,
        AppAPIError.transport("technical transport detail")
    ])
    func knownAPIErrorsMapToUserSafeMessages(error: AppAPIError) {
        let message = AppErrorMapper.userMessage(for: error)

        #expect(message.isEmpty == false)
        #expect(message.contains("technical") == false)
    }

    @Test("Unknown errors map to generic retry-safe copy")
    func unknownErrorsMapToGenericCopy() {
        struct UnknownError: Error {}

        let message = AppErrorMapper.userMessage(for: UnknownError())

        #expect(message == "Something went wrong. Please try again.")
    }
}
