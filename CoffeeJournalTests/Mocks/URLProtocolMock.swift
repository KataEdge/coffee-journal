import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class URLProtocolMock: URLProtocol {
    public static var testURLs: [URL: (Data?, URLResponse?, Error?)] = [:]
    public static var responseHandler: ((URLRequest) -> (Data?, URLResponse?, Error?))?

    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        if let handler = URLProtocolMock.responseHandler {
            let (data, response, error) = handler(request)
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
            return
        }

        if let url = request.url, let (data, response, error) = URLProtocolMock.testURLs[url] {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        } else {
            let response = HTTPURLResponse(
                url: request.url ?? URL(string: "https://example.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )
            let emptyJson = "{}".data(using: .utf8)!
            client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: emptyJson)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override public func stopLoading() {}
}
