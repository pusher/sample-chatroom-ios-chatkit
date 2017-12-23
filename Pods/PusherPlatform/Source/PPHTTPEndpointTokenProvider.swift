import Foundation

public class PPHTTPEndpointTokenProvider: PPTokenProvider {
    public var url: String

    // TODO: Seems like there is a better name for this

    public var requestInjector: ((PPHTTPEndpointTokenProviderRequest) -> (PPHTTPEndpointTokenProviderRequest))?
    public var accessToken: String? = nil
    public var refreshToken: String? = nil
    public internal(set) var accessTokenExpiresAt: Double? = nil
    public var retryStrategy: PPRetryStrategy
    public var logger: PPLogger? = nil {
        willSet {
            (self.retryStrategy as? PPDefaultRetryStrategy)?.logger = newValue
        }
    }

    public init(
        url: String,
        requestInjector: ((PPHTTPEndpointTokenProviderRequest) -> (PPHTTPEndpointTokenProviderRequest))? = nil,
        retryStrategy: PPRetryStrategy = PPDefaultRetryStrategy()
    ) {
        self.url = url
        self.requestInjector = requestInjector
        self.retryStrategy = retryStrategy
    }

    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {

        // TODO: [unowned self] ?

        let retryAwareCompletionHandler = { (tokenProviderResult: PPTokenProviderResult) in
            switch tokenProviderResult {
            case .error(let err):
                let shouldRetryResult = self.retryStrategy.shouldRetry(given: err)

                switch shouldRetryResult {
                case .retry(let retryWaitTimeInterval):
                    // TODO: [unowned self] here as well?

                    DispatchQueue.main.asyncAfter(deadline: .now() + retryWaitTimeInterval, execute: { [unowned self] in
                        self.fetchToken(completionHandler: completionHandler)
                    })
                case .doNotRetry(let reasonErr):
                    completionHandler(PPTokenProviderResult.error(error: reasonErr))
                }
                return
            case .success(let token):
                self.retryStrategy.requestSucceeded()
                completionHandler(PPTokenProviderResult.success(token: token))
            }
        }

        if let token = self.accessToken, let tokenExpiryTime = self.accessTokenExpiresAt {
            guard tokenExpiryTime > Date().timeIntervalSince1970 else {
                if self.refreshToken != nil {
                    refreshAccessToken(completionHandler: retryAwareCompletionHandler)
                } else {
                    getTokenPair(completionHandler: retryAwareCompletionHandler)
                }
                // TODO: Is returning here correct?
                return
            }
            completionHandler(PPTokenProviderResult.success(token: token))
        } else {
            getTokenPair(completionHandler: retryAwareCompletionHandler)
        }
    }

    fileprivate func getTokenPair(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeAuthRequest(grantType: PPEndpointRequestGrantType.clientCredentials, completionHandler: completionHandler)
    }

    fileprivate func refreshAccessToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeAuthRequest(grantType: PPEndpointRequestGrantType.refreshToken, completionHandler: completionHandler)
    }

    fileprivate func makeAuthRequest(grantType: PPEndpointRequestGrantType, completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        let authRequestResult = prepareAuthRequest(grantType: grantType)

        guard let request = authRequestResult.request, authRequestResult.error == nil else {
            completionHandler(PPTokenProviderResult.error(error: authRequestResult.error!))
            return
        }

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, sessionError in
            do {
                let tokenProviderResponse = try self.validateCompletionValues(data: data, response: response, sessionError: sessionError)

                self.accessToken = tokenProviderResponse.accessToken
                self.refreshToken = tokenProviderResponse.refreshToken
                self.accessTokenExpiresAt = Date().timeIntervalSince1970 + tokenProviderResponse.expiresIn

                self.logger?.log("Successful request to get token: \(tokenProviderResponse.accessToken)", logLevel: .verbose)

                completionHandler(PPTokenProviderResult.success(token: tokenProviderResponse.accessToken))
            } catch let err {
                self.logger?.log(err.localizedDescription, logLevel: .verbose)
                completionHandler(PPTokenProviderResult.error(error: err))
            }
        }).resume()
    }

    fileprivate func validateCompletionValues(data: Data?, response: URLResponse?, sessionError: Error?) throws -> PPTokenProviderResponse {
        if let error = sessionError {
            throw error
        }

        guard let data = data else {
            throw PPHTTPEndpointTokenProviderError.noDataPresent
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PPHTTPEndpointTokenProviderError.invalidHTTPResponse(response: response, data: data)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw PPHTTPEndpointTokenProviderError.badResponseStatusCode(response: httpResponse, data: data)
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw PPHTTPEndpointTokenProviderError.failedToDeserializeJSON(data)
        }

        guard let json = jsonObject as? [String: Any] else {
            throw PPHTTPEndpointTokenProviderError.failedToCastJSONObjectToDictionary(jsonObject)
        }

        guard let accessToken = json["access_token"] as? String else {
            throw PPHTTPEndpointTokenProviderError.validAccessTokenNotPresentInResponseJSON(json)
        }

        guard let refreshToken = json["refresh_token"] as? String else {
            throw PPHTTPEndpointTokenProviderError.validRefreshTokenNotPresentInResponseJSON(json)
        }

        // TODO: Check if Double is sensible type here
        guard let expiresIn = json["expires_in"] as? TimeInterval else {
            throw PPHTTPEndpointTokenProviderError.validExpiresInNotPresentInResponseJSON(json)
        }

        return PPTokenProviderResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }


    fileprivate func prepareAuthRequest(grantType: PPEndpointRequestGrantType) -> (request: URLRequest?, error: Error?) {
        guard var endpointURLComponents = URLComponents(string: self.url) else {
            return (request: nil, error: PPHTTPEndpointTokenProviderError.failedToCreateURLComponents(self.url))
        }

        var httpEndpointRequest: PPHTTPEndpointTokenProviderRequest? = nil

        if requestInjector != nil {
            httpEndpointRequest = requestInjector!(PPHTTPEndpointTokenProviderRequest())
        }

        let grantBodyString = "grant_type=\(grantType.rawValue)"

        if let httpEndpointRequest = httpEndpointRequest {
            if endpointURLComponents.queryItems != nil {
                endpointURLComponents.queryItems!.append(contentsOf: httpEndpointRequest.queryItems)
            } else {
                endpointURLComponents.queryItems = httpEndpointRequest.queryItems
            }
        }

        guard let endpointURL = endpointURLComponents.url else {
            return (request: nil, error: PPHTTPEndpointTokenProviderError.failedToCreateURLObject(endpointURLComponents))
        }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if httpEndpointRequest != nil {
            for (key, val) in httpEndpointRequest!.headers {
                request.setValue(val, forHTTPHeaderField: key)
            }

            if let body = httpEndpointRequest!.body {
                let queryString = PPHTTPBodyPair.queryString(body: body)
                request.httpBody = "\(grantBodyString)&\(queryString)".data(using: .utf8)
            } else {
                request.httpBody = grantBodyString.data(using: .utf8)
            }
        } else {
            request.httpBody = grantBodyString.data(using: .utf8)
        }

        return (request: request, error: nil)
    }
}

fileprivate struct PPTokenProviderResponse {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
}

public enum PPEndpointRequestGrantType: String {
    case clientCredentials = "client_credentials"
    case refreshToken = "refresh_token"
}

// TODO: This should probably be replaced by PPRequestOptions

public class PPHTTPEndpointTokenProviderRequest {
    public var headers: [String: String] = [:]
    public var body: PPHTTPBody? = []
    public var queryItems: [URLQueryItem] = []

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

public enum PPHTTPEndpointTokenProviderError: Error {
    case failedToCreateURLComponents(String)
    case failedToCreateURLObject(URLComponents)
    case noDataPresent
    case invalidHTTPResponse(response: URLResponse?, data: Data)
    case badResponseStatusCode(response: HTTPURLResponse, data: Data)
    case failedToDeserializeJSON(Data)
    case failedToCastJSONObjectToDictionary(Any)
    case validAccessTokenNotPresentInResponseJSON([String: Any])
    case validRefreshTokenNotPresentInResponseJSON([String: Any])
    case validExpiresInNotPresentInResponseJSON([String: Any])
}

extension PPHTTPEndpointTokenProviderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToCreateURLComponents(let errorString):
            return "Failed to parse URL into components. Error: \(errorString)"
        case .failedToCreateURLObject(let urlComponents):
            return "URL component doesn't exist in: \(urlComponents)"
        case .noDataPresent:
            return "No data present"
        case .invalidHTTPResponse(let response, _):
            return "Invalid HTTP response: \(response.debugDescription)"
        case .badResponseStatusCode(let response, _):
            return "Bad response code: \(response.statusCode)"
        case .failedToDeserializeJSON(let data):
            return "Failed to deserialize JSON with data: \(data)"
        case .failedToCastJSONObjectToDictionary(let jsonObject):
            return "Failed to cast JSON object: \(jsonObject) to dictionary"
        case .validAccessTokenNotPresentInResponseJSON(let json):
            return "Valid \"access_token\" value not present in response JSON: \(json)"
        case .validRefreshTokenNotPresentInResponseJSON(let json):
            return "Valid \"refresh_token\" value not present in response JSON: \(json)"
        case .validExpiresInNotPresentInResponseJSON(let json):
            return "Valid \"expires_in\" value not present in response JSON: \(json)"
        }
    }
}
