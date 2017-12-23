import Foundation

// TODO: This should probably be a protocol which PPSubscribeRequestOptions
// and PPGeneralRequestOptions conform to

public class PPRequestOptions {
    public let method: String
    public var path: String
    public internal(set) var queryItems: [URLQueryItem]
    public internal(set) var headers: [String: String]
    public let body: Data?
    public var retryStrategy: PPRetryStrategy?

    public init(
        method: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        retryStrategy: PPRetryStrategy? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.retryStrategy = retryStrategy
    }

    // If a header key already exists then calling this will override it
    public func addHeaders(_ newHeaders: [String: String]) {
        for header in newHeaders {
            self.headers[header.key] = header.value
        }
    }

    public func addQueryItems(_ newQueryItems: [URLQueryItem]) {
        self.queryItems.append(contentsOf: newQueryItems)
    }
}

extension PPRequestOptions: CustomDebugStringConvertible {
    public var debugDescription: String {
        let debugString = "\(self.method) request to \(self.path))"
        var extraInfo = [debugString]

        if self.queryItems.count > 0 {
            extraInfo.append("Query items: \(self.queryItems.map { $0.debugDescription }.joined(separator: ", "))")
        }

        if self.headers.count > 0 {
            extraInfo.append("Headers: \(self.headers.map { "\($0.key): \($0.value)" }.joined(separator: ", "))")
        }

        if let body = self.body, let bodyString = String(data: body, encoding: .utf8) {
            extraInfo.append("Body: \(bodyString)")
        }

        return extraInfo.joined(separator: "\n")
    }
}

