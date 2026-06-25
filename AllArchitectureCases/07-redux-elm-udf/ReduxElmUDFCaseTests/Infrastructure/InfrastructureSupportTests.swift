import Foundation
import Testing
import UIKit
@testable import ReduxElmUDFCase

@Suite("Infrastructure support tests")
struct InfrastructureSupportTests {
    @Test("APIConfiguration allows DummyJSON fallback only for demo mode")
    func apiConfigurationAllowsDemoFallbackOnlyForDemoMode() throws {
        let demoConfiguration = try APIConfiguration.make(environment: [
            "REDUX_ELM_UDF_CASE_ALLOW_DEMO_CREDENTIALS": "true"
        ])
        #expect(demoConfiguration.environment == .demo)
        #expect(demoConfiguration.baseURL.absoluteString == "https://dummyjson.com")

        #expect(throws: APIConfigurationError.missingProductionBaseURL) {
            _ = try APIConfiguration.make(environment: [
                "REDUX_ELM_UDF_CASE_ALLOW_DEMO_CREDENTIALS": "false"
            ])
        }
    }

    @Test("APIConfiguration rejects invalid explicit base URL")
    func apiConfigurationRejectsInvalidExplicitBaseURL() {
        #expect(throws: APIConfigurationError.invalidBaseURL("not-a-url")) {
            _ = try APIConfiguration.makeBaseURL(
                from: ["REDUX_ELM_UDF_CASE_API_BASE_URL": "not-a-url"],
                allowsDemoFallback: true
            )
        }
    }

    @Test("JSONRequestBodyEncoder propagates encoding failures")
    func jsonRequestBodyEncoderPropagatesEncodingFailures() {
        #expect(throws: NeverEncodable.EncodingFailure.self) {
            _ = try JSONRequestBodyEncoder.encode(NeverEncodable())
        }
    }

    @Test("AppErrorMapper hides technical transport details")
    func appErrorMapperHidesTechnicalTransportDetails() {
        let message = AppErrorMapper.userMessage(for: AppAPIError.transport("raw socket failure"))
        #expect(message == "The network request failed. Please try again.")
    }

    @Test("Network client retries idempotent GET and decodes success response")
    func networkClientRetriesIdempotentGETAndDecodesSuccessResponse() async throws {
        let url = try #require(URL(string: "https://example.test/products"))
        URLProtocolStubRegistry.register(
            responses: [
                .failure(URLError(.timedOut)),
                .success((HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data(#"{"value":"ok"}"#.utf8)))
            ],
            for: url
        )
        defer { URLProtocolStubRegistry.remove(url) }

        let client = URLSessionNetworkClient(
            configuration: NetworkClientConfiguration(
                baseURL: try #require(URL(string: "https://example.test")),
                requestTimeout: 3,
                retryPolicy: .idempotentGET(maxRetries: 1, retryDelay: 0)
            ),
            session: Self.stubbedSession(),
            errorMapping: .appAPIError,
            retrySleeper: { _ in }
        )

        let response: TestResponse = try await client.send(TestGETRequest(path: "products"))

        #expect(response.value == "ok")
        #expect(URLProtocolStubRegistry.requestCount(for: url) == 2)
    }

    @Test("Network client maps unauthorized response to app API error")
    func networkClientMapsUnauthorizedResponseToAppAPIError() async throws {
        let url = try #require(URL(string: "https://example.test/me"))
        URLProtocolStubRegistry.register(
            responses: [
                .success((HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!, Data(#"{"message":"expired"}"#.utf8)))
            ],
            for: url
        )
        defer { URLProtocolStubRegistry.remove(url) }

        let client = URLSessionNetworkClient(
            configuration: NetworkClientConfiguration(
                baseURL: try #require(URL(string: "https://example.test")),
                requestTimeout: 3,
                retryPolicy: .idempotentGET(maxRetries: 0)
            ),
            session: Self.stubbedSession(),
            errorMapping: .appAPIError
        )

        await #expect(throws: AppAPIError.unauthorized("expired")) {
            let _: TestResponse = try await client.send(TestGETRequest(path: "me"))
        }
    }

    @Test("Image memory cache stores downsampled images by key")
    func imageMemoryCacheStoresImagesByKey() throws {
        let cache = ImageMemoryCache(countLimit: 1, totalCostLimit: 512 * 1024)
        let image = try #require(Self.makeImage())

        cache.insert(image, forKey: "avatar")

        #expect(cache.image(forKey: "avatar") === image)
    }

    @Test("RemoteImagePipeline downsampling uses memory cache on repeat load")
    func remoteImagePipelineUsesMemoryCacheOnRepeatLoad() async throws {
        let url = try #require(URL(string: "https://example.test/image.png"))
        let imageData = try #require(Self.makeImage()?.pngData())
        URLProtocolStubRegistry.register(
            responses: [
                .success((HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, imageData))
            ],
            for: url
        )
        defer { URLProtocolStubRegistry.remove(url) }

        let pipeline = RemoteImagePipeline(session: Self.stubbedSession(), cache: ImageMemoryCache())

        let first = try await pipeline.image(from: url, targetSize: CGSize(width: 32, height: 32), scale: 2)
        let second = try await pipeline.image(from: url, targetSize: CGSize(width: 32, height: 32), scale: 2)

        #expect(first === second)
        #expect(URLProtocolStubRegistry.requestCount(for: url) == 1)
    }

    private static func stubbedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }

    private static func makeImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
        }
    }
}

private struct NeverEncodable: Encodable {
    struct EncodingFailure: Error, Equatable {}

    func encode(to encoder: Encoder) throws {
        throw EncodingFailure()
    }
}

private struct TestResponse: Decodable, Equatable {
    let value: String
}

private struct TestGETRequest: NetworkRequest {
    let path: String
    let method: NetworkHTTPMethod = .get
}

private enum URLProtocolStubRegistry {
    typealias StubResponse = Result<(HTTPURLResponse, Data), Error>

    private static let lock = NSLock()
    private static var responsesByURL: [URL: [StubResponse]] = [:]
    private static var countsByURL: [URL: Int] = [:]

    static func register(responses: [StubResponse], for url: URL) {
        lock.withLock {
            responsesByURL[url] = responses
            countsByURL[url] = 0
        }
    }

    static func nextResponse(for url: URL) -> StubResponse? {
        lock.withLock {
            countsByURL[url, default: 0] += 1
            guard var responses = responsesByURL[url], !responses.isEmpty else { return nil }
            let response = responses.removeFirst()
            responsesByURL[url] = responses
            return response
        }
    }

    static func requestCount(for url: URL) -> Int {
        lock.withLock { countsByURL[url, default: 0] }
    }

    static func remove(_ url: URL) {
        lock.withLock {
            responsesByURL.removeValue(forKey: url)
            countsByURL.removeValue(forKey: url)
        }
    }
}

private final class StubURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url, let response = URLProtocolStubRegistry.nextResponse(for: url) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        switch response {
        case .success(let payload):
            client?.urlProtocol(self, didReceive: payload.0, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: payload.1)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
