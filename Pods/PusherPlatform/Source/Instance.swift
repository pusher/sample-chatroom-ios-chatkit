import Foundation

@objc public class Instance: NSObject {
    public let id: String
    public var serviceName: String
    public var serviceVersion: String
    public var host: String
    public var tokenProvider: PPTokenProvider?
    public var client: PPBaseClient
    public var logger: PPLogger {
        willSet {
            self.client.logger = newValue
        }
    }

    public init(
        instanceId: String,
        serviceName: String,
        serviceVersion: String,
        tokenProvider: PPTokenProvider? = nil,
        client: PPBaseClient? = nil,
        logger: PPLogger? = nil
    ) {
        assert (!instanceId.isEmpty, "Expected instanceId property in Instance!")
        let splitInstance = instanceId.components(separatedBy: ":")
        assert(splitInstance.count == 3, "Expecting instanceId in the format of 'v1:us1:1a234-123a-1234-12a3-1234123aa12' but got this instead: '\(instanceId)'. Check the dashboard to ensure you have a properly formatted instanceId.")
        assert(!serviceName.isEmpty, "Expected serviceName property in Instance options!")
        assert(!serviceVersion.isEmpty, "Expected serviceVersion property in Instance otpions!")

        self.id = splitInstance[2]
        self.serviceName = serviceName
        self.serviceVersion = serviceVersion
        self.tokenProvider = tokenProvider

        let cluster = splitInstance[1]
        let host = "\(cluster).pusherplatform.io"
        self.host = host
        self.client = client ?? PPBaseClient(host: host)

        self.logger = logger ?? PPDefaultLogger()
        if self.client.logger == nil {
            self.client.logger = self.logger
        }
    }

    @discardableResult
    public func request(
        using requestOptions: PPRequestOptions,
        onSuccess: ((Data) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> PPRequest {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        var generalRequest = PPRequest(type: .general)

        if self.tokenProvider != nil {
            self.tokenProvider!.fetchToken { result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])
                    self.client.request(
                        with: &generalRequest,
                        using: mutableBaseClientRequestOptions,
                        onSuccess: onSuccess,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.request(
                with: &generalRequest,
                using: mutableBaseClientRequestOptions,
                onSuccess: onSuccess,
                onError: onError
            )
        }

        return generalRequest
    }

    @discardableResult
    public func requestWithRetry(
        using requestOptions: PPRequestOptions,
        onSuccess: ((Data) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> PPRetryableGeneralRequest {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        var generalRetryableRequest = PPRetryableGeneralRequest(instance: self, requestOptions: requestOptions)

        if self.tokenProvider != nil {
            self.tokenProvider!.fetchToken { result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])
                    self.client.requestWithRetry(
                        with: &generalRetryableRequest,
                        using: mutableBaseClientRequestOptions,
                        onSuccess: onSuccess,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.requestWithRetry(
                with: &generalRetryableRequest,
                using: mutableBaseClientRequestOptions,
                onSuccess: onSuccess,
                onError: onError
            )
        }

        return generalRetryableRequest
    }

    public func subscribe(
        with subscription: inout PPRequest,
        using requestOptions: PPRequestOptions,
        onOpening: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onEvent: ((String, [String: String], Any) -> Void)? = nil,
        onEnd: ((Int?, [String: String]?, Any?) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        if self.tokenProvider != nil {
            // TODO: The weak here feels dangerous, also probably should be weak self

            self.tokenProvider!.fetchToken { [weak subscription] result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])

                    self.client.subscribe(
                        with: &subscription!,
                        using: mutableBaseClientRequestOptions,
                        onOpening: onOpening,
                        onOpen: onOpen,
                        onEvent: onEvent,
                        onEnd: onEnd,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.subscribe(
                with: &subscription,
                using: mutableBaseClientRequestOptions,
                onOpening: onOpening,
                onOpen: onOpen,
                onEvent: onEvent,
                onEnd: onEnd,
                onError: onError
            )
        }
    }

    public func subscribeWithResume(
        with resumableSubscription: inout PPResumableSubscription,
        using requestOptions: PPRequestOptions,
        onOpening: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onResuming: (() -> Void)? = nil,
        onEvent: ((String, [String: String], Any) -> Void)? = nil,
        onEnd: ((Int?, [String: String]?, Any?) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        if self.tokenProvider != nil {
            self.tokenProvider!.fetchToken { [weak resumableSubscription] result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])

                    self.client.subscribeWithResume(
                        with: &resumableSubscription!,
                        using: mutableBaseClientRequestOptions,
                        instance: self,
                        onOpening: onOpening,
                        onOpen: onOpen,
                        onResuming: onResuming,
                        onEvent: onEvent,
                        onEnd: onEnd,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.subscribeWithResume(
                with: &resumableSubscription,
                using: mutableBaseClientRequestOptions,
                instance: self,
                onOpening: onOpening,
                onOpen: onOpen,
                onResuming: onResuming,
                onEvent: onEvent,
                onEnd: onEnd,
                onError: onError
            )
        }
    }

    public func subscribe(
        using requestOptions: PPRequestOptions,
        onOpening: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onEvent: ((String, [String: String], Any) -> Void)? = nil,
        onEnd: ((Int?, [String: String]?, Any?) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> PPRequest {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        var subscription = PPRequest(type: .subscription)

        if self.tokenProvider != nil {
            self.tokenProvider!.fetchToken { result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])

                    self.client.subscribe(
                        with: &subscription,
                        using: mutableBaseClientRequestOptions,
                        onOpening: onOpening,
                        onOpen: onOpen,
                        onEvent: onEvent,
                        onEnd: onEnd,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.subscribe(
                with: &subscription,
                using: mutableBaseClientRequestOptions,
                onOpening: onOpening,
                onOpen: onOpen,
                onEvent: onEvent,
                onEnd: onEnd,
                onError: onError
            )
        }

        return subscription
    }

    public func subscribeWithResume(
        using requestOptions: PPRequestOptions,
        onOpening: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onResuming: (() -> Void)? = nil,
        onEvent: ((String, [String: String], Any) -> Void)? = nil,
        onEnd: ((Int?, [String: String]?, Any?) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> PPResumableSubscription {
        let namespacedPath = namespace(path: requestOptions.path)

        let mutableBaseClientRequestOptions = requestOptions
        mutableBaseClientRequestOptions.path = namespacedPath

        var resumableSubscription = PPResumableSubscription(instance: self, requestOptions: requestOptions)

        if self.tokenProvider != nil {
            // TODO: Does resumableSubscription need to be weak here?

            self.tokenProvider!.fetchToken { [weak resumableSubscription] result in
                switch result {
                case .error(let error): onError?(error)
                case .success(let jwtFromTokenProvider):
                    let authHeaderValue = "Bearer \(jwtFromTokenProvider)"
                    mutableBaseClientRequestOptions.addHeaders(["Authorization": authHeaderValue])

                    self.client.subscribeWithResume(
                        with: &resumableSubscription!,
                        using: mutableBaseClientRequestOptions,
                        instance: self,
                        onOpening: onOpening,
                        onOpen: onOpen,
                        onResuming: onResuming,
                        onEvent: onEvent,
                        onEnd: onEnd,
                        onError: onError
                    )
                }
            }
        } else {
            self.client.subscribeWithResume(
                with: &resumableSubscription,
                using: mutableBaseClientRequestOptions,
                instance: self,
                onOpening: onOpening,
                onOpen: onOpen,
                onResuming: onResuming,
                onEvent: onEvent,
                onEnd: onEnd,
                onError: onError
            )
        }

        return resumableSubscription
    }

    public func unsubscribe(taskIdentifier: Int, completionHandler: ((Error?) -> Void)? = nil) {
        self.client.unsubscribe(taskIdentifier: taskIdentifier, completionHandler: completionHandler)
    }

    internal func sanitise(path: String) -> String {
        var sanitisedPath = ""

        for char in path.characters {
            // only append a slash if last character isn't already a slash
            if char == "/" {
                if !sanitisedPath.hasSuffix("/") {
                    sanitisedPath.append(char)
                }
            } else {
                sanitisedPath.append(char)
            }
        }

        // remove trailing slash
        if sanitisedPath.hasSuffix("/") {
            sanitisedPath.remove(at: sanitisedPath.index(before: sanitisedPath.endIndex))
        }

        // ensure leading slash
        if !sanitisedPath.hasPrefix("/") {
            sanitisedPath = "/\(sanitisedPath)"
        }

        return sanitisedPath
    }

    internal func namespace(path: String) -> String {
        if path.hasPrefix("/services/") {
            return path
        }

        return sanitise(path: "services/\(self.serviceName)/\(self.serviceVersion)/\(self.id)/\(path)")
    }
}
