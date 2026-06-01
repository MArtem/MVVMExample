import Foundation
import Testing
import AppConfiguration
import AppErrors
import AppLogging
@testable import AppNetworking

@Suite("URLSession network client tests")
struct URLSessionNetworkClientTests {
    @Test("Successful response decodes typed payload")
    func successfulResponseDecodesTypedPayload() async throws {
        let fixture = makeClient(
            statusCode: 200,
            body: #"{"name":"fixture"}"#.data(using: .utf8)!
        )

        let response: ResponseDTO = try await fixture.client.send(TestRequest(path: "/resource"))

        #expect(response.name == "fixture")
    }

    @Test("Unauthorized response maps to AppAPIError unauthorized")
    func unauthorizedResponseMapsToUnauthorized() async throws {
        let fixture = makeClient(
            statusCode: 401,
            body: #"{"message":"expired"}"#.data(using: .utf8)!
        )

        do {
            let _: ResponseDTO = try await fixture.client.send(TestRequest(path: "/resource"))
            Issue.record("Expected unauthorized error")
        } catch AppAPIError.unauthorized(let message) {
            #expect(message == "expired")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Decoding failure maps to AppAPIError decoding")
    func decodingFailureMapsToDecoding() async throws {
        let fixture = makeClient(
            statusCode: 200,
            body: #"{"unexpected":"fixture"}"#.data(using: .utf8)!
        )

        do {
            let _: ResponseDTO = try await fixture.client.send(TestRequest(path: "/resource"))
            Issue.record("Expected decoding error")
        } catch AppAPIError.decoding(let message) {
            #expect(message.isEmpty == false)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("POST requests are not retried by idempotent GET policy")
    func postRequestsAreNotRetriedByIdempotentGETPolicy() async throws {
        let fixture = makeClient(
            statusCode: 500,
            body: Data(),
            retryPolicy: .idempotentGET(maxRetries: 2, retryDelay: 0)
        )

        do {
            let _: ResponseDTO = try await fixture.client.send(TestRequest(path: "/resource", method: .post))
            Issue.record("Expected server error")
        } catch AppAPIError.server {
            #expect(MockURLProtocol.requestCount(for: fixture.requestURL) == 1)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    private func makeClient(
        statusCode: Int,
        body: Data,
        retryPolicy: APIRetryPolicy = .idempotentGET(maxRetries: 0)
    ) -> ClientFixture {
        let baseURL = URL(string: "https://\(UUID().uuidString).example.com")!
        let requestURL = baseURL.appendingPathComponent("resource")
        MockURLProtocol.configure(
            url: requestURL,
            statusCode: statusCode,
            body: body,
            error: nil
        )

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)

        return ClientFixture(
            client: URLSessionNetworkClient(
                configuration: APIConfiguration(
                    environment: .demo,
                    baseURL: baseURL,
                    requestTimeout: 5,
                    allowsDemoCredentials: true,
                    retryPolicy: retryPolicy
                ),
                session: session,
                logger: NoOpAppLogger()
            ),
            requestURL: requestURL
        )
    }
}

private struct ClientFixture {
    let client: URLSessionNetworkClient
    let requestURL: URL
}

private struct ResponseDTO: Decodable {
    let name: String
}

private struct TestRequest: NetworkRequest {
    let path: String
    let method: NetworkHTTPMethod

    init(path: String, method: NetworkHTTPMethod = .get) {
        self.path = path
        self.method = method
    }
}

private final class MockURLProtocol: URLProtocol {
    private struct Stub {
        let statusCode: Int
        let body: Data
        let error: Error?
        var requestCount: Int
    }

    private static let lock = NSLock()
    private static var stubs: [URL: Stub] = [:]

    static func configure(url: URL, statusCode: Int, body: Data, error: Error?) {
        lock.withLock {
            stubs[url] = Stub(statusCode: statusCode, body: body, error: error, requestCount: 0)
        }
    }

    static func requestCount(for url: URL) -> Int {
        lock.withLock { stubs[url]?.requestCount ?? 0 }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        let stub = Self.lock.withLock {
            guard var stub = Self.stubs[url] else { return nil as Stub? }
            stub.requestCount += 1
            Self.stubs[url] = stub
            return stub
        }

        guard let stub else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private extension NSLock {
    func withLock<Value>(_ body: () throws -> Value) rethrows -> Value {
        lock()
        defer { unlock() }
        return try body()
    }
}
