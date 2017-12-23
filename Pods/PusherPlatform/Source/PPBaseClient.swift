import Foundation

let REALLY_LONG_TIME: Double = 252_460_800

@objc public class PPBaseClient: NSObject {
    public var port: Int?
    internal var baseUrlComponents: URLComponents

    // The subscriptionURLSession requires a different URLSessionConfiguration, which
    // is why it is separated from the generalRequestURLSession
    public let subscriptionURLSession: URLSession
    public let subscriptionSessionDelegate: PPURLSessionDelegate

    public let generalRequestURLSession: URLSession
    public let generalRequestSessionDelegate: PPURLSessionDelegate

    public var logger: PPLogger? = nil {
        willSet {
            self.subscriptionSessionDelegate.logger = newValue
            self.generalRequestSessionDelegate.logger = newValue
        }
    }

    // Should be between 30 and 300
    public let heartbeatTimeout: Int

    // Should be between 0 and 10240 (to avoid 422 response) - we don't need any
    // initial data because the custom content type header means that no data
    // gets buffered by URLSession
    public let heartbeatInitialSize: Int

    // Set to true if you want to trust all certificates
    public let insecure: Bool

    // If you want to provide a closure that builds a PPRetryStrategy based on
    // a request's options then you can use this property
    public var retryStrategyBuilder: (PPRequestOptions) -> PPRetryStrategy

    public var clientName: String
    public var clientVersion: String

    public init(
        host: String,
        port: Int? = nil,
        insecure: Bool = false,
        clientName: String = "pusher-platform-swift",
        retryStrategyBuilder: @escaping (PPRequestOptions) -> PPRetryStrategy = PPBaseClient.methodAwareRetryStrategyGenerator,
        heartbeatTimeoutInterval: Int = 60,
        heartbeatInitialSize: Int = 0
    ) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.port = port

        self.baseUrlComponents = urlComponents
        self.insecure = insecure
        self.clientName = clientName
        self.clientVersion = "0.1.30"
        self.retryStrategyBuilder = retryStrategyBuilder
        self.heartbeatTimeout = heartbeatTimeoutInterval
        self.heartbeatInitialSize = heartbeatInitialSize

        let subscriptionSessionConfiguration = URLSessionConfiguration.default
        subscriptionSessionConfiguration.timeoutIntervalForResource = REALLY_LONG_TIME
        subscriptionSessionConfiguration.timeoutIntervalForRequest = REALLY_LONG_TIME
        subscriptionSessionConfiguration.httpAdditionalHeaders = [
            "X-Heartbeat-Interval": String(self.heartbeatTimeout),
            "X-Initial-Heartbeat-Size": String(self.heartbeatInitialSize)
        ]

        self.subscriptionSessionDelegate = PPURLSessionDelegate(insecure: insecure)
        self.generalRequestSessionDelegate = PPURLSessionDelegate(insecure: insecure)

        self.subscriptionURLSession = URLSession(
            configuration: subscriptionSessionConfiguration,
            delegate: self.subscriptionSessionDelegate,
            delegateQueue: nil
        )

        self.generalRequestURLSession = URLSession(
            configuration: .default,
            delegate: self.generalRequestSessionDelegate,
            delegateQueue: nil
        )
    }

    deinit {
        self.subscriptionURLSession.invalidateAndCancel()
        self.generalRequestURLSession.invalidateAndCancel()
    }

    public func request(
        with generalRequest: inout PPRequest,
        using requestOptions: PPRequestOptions,
        onSuccess: ((Data) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        var mutableURLComponents = self.baseUrlComponents
        mutableURLComponents.queryItems = requestOptions.queryItems

        self.logger?.log(
            "URLComponents for request in base client: \(mutableURLComponents.debugDescription)",
            logLevel: .verbose
        )

        guard var url = mutableURLComponents.url else {
            onError?(PPBaseClientError.invalidURL(components: mutableURLComponents))
            return
        }

        url = url.appendingPathComponent(requestOptions.path)

        self.logger?.log("URL for request in base client: \(url)", logLevel: .verbose)

        var request = URLRequest(url: url)
        request.httpMethod = requestOptions.method

        for (header, value) in requestOptions.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if let body = requestOptions.body {
            request.httpBody = body
        }

        let task: URLSessionDataTask = self.generalRequestURLSession.dataTask(with: request)

        // TODO: We should really be locking the sessionDelegate's list of requests for the check
        // and the assignment together
        guard self.generalRequestSessionDelegate[task] == nil else {
            onError?(PPBaseClientError.preExistingTaskIdentifierForRequest)
            return
        }

        self.generalRequestSessionDelegate[task] = generalRequest

        generalRequest.options = requestOptions

        guard let generalRequestDelegate = generalRequest.delegate as? PPGeneralRequestDelegate else {
            onError?(
                PPBaseClientError.requestHasInvalidDelegate(
                    request: generalRequest,
                    delegate: generalRequest.delegate
                )
            )
            return
        }

        // Pass through logger where required
        generalRequestDelegate.logger = self.logger
        generalRequestDelegate.task = task
        generalRequestDelegate.onSuccess = onSuccess
        generalRequestDelegate.onError = onError

        task.resume()
    }

    public func requestWithRetry(
        with retryableGeneralRequest: inout PPRetryableGeneralRequest,
        using requestOptions: PPRequestOptions,
        onSuccess: ((Data) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        var mutableURLComponents = self.baseUrlComponents
        mutableURLComponents.queryItems = requestOptions.queryItems

        self.logger?.log(
            "URLComponents for requestWithRetry in base client: \(mutableURLComponents.debugDescription)",
            logLevel: .verbose
        )

        guard var url = mutableURLComponents.url else {
            onError?(PPBaseClientError.invalidURL(components: mutableURLComponents))
            return
        }

        url = url.appendingPathComponent(requestOptions.path)

        self.logger?.log("URL for requestWithRetry in base client: \(url)", logLevel: .verbose)

        var request = URLRequest(url: url)
        request.httpMethod = requestOptions.method

        for (header, value) in requestOptions.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        if let body = requestOptions.body {
            request.httpBody = body
        }

        let task: URLSessionDataTask = self.generalRequestURLSession.dataTask(with: request)

        guard self.generalRequestSessionDelegate[task] == nil else {
            onError?(PPBaseClientError.preExistingTaskIdentifierForRequest)
            return
        }

        let generalRequest = PPRequest(type: .general)
        generalRequest.options = requestOptions

        self.generalRequestSessionDelegate[task] = generalRequest

        guard let generalRequestDelegate = generalRequest.delegate as? PPGeneralRequestDelegate else {
            onError?(
                PPBaseClientError.requestHasInvalidDelegate(
                    request: generalRequest,
                    delegate: generalRequest.delegate
                )
            )
            return
        }

        generalRequestDelegate.task = task

        retryableGeneralRequest.generalRequest = generalRequest

        // Retry strategy from PPRequestOptions takes precedent, otherwise falls back to the
        // PPRetryStrategy set in the BaseClient, which is PPDefaultRetryStrategy unless
        // otherwise set
        if let reqOptionsRetryStrategy = requestOptions.retryStrategy {
            retryableGeneralRequest.retryStrategy = reqOptionsRetryStrategy
        } else {
            retryableGeneralRequest.retryStrategy = self.retryStrategyBuilder(requestOptions)
        }

        retryableGeneralRequest.onSuccess = onSuccess
        retryableGeneralRequest.onError = onError

        // Pass through logger where required
        generalRequestDelegate.logger = self.logger
        (retryableGeneralRequest.retryStrategy as? PPDefaultRetryStrategy)?.logger = self.logger

        task.resume()
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
        var mutableURLComponents = self.baseUrlComponents
        mutableURLComponents.queryItems = requestOptions.queryItems

        self.logger?.log(
            "URLComponents for subscribe in base client: \(mutableURLComponents.debugDescription)",
            logLevel: .verbose
        )

        guard var url = mutableURLComponents.url else {
            onError?(PPBaseClientError.invalidURL(components: mutableURLComponents))
            return
        }

        url = url.appendingPathComponent(requestOptions.path)

        self.logger?.log("URL for subscribe in base client: \(url)", logLevel: .verbose)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.SUBSCRIBE.rawValue
        request.timeoutInterval = REALLY_LONG_TIME

        for (header, value) in requestOptions.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        let task: URLSessionDataTask = self.subscriptionURLSession.dataTask(with: request)

        guard self.subscriptionSessionDelegate[task] == nil else {
            onError?(PPBaseClientError.preExistingTaskIdentifierForRequest)
            return
        }

        self.subscriptionSessionDelegate[task] = subscription

        subscription.options = requestOptions

        guard let subscriptionDelegate = subscription.delegate as? PPSubscriptionDelegate else {
            onError?(
                PPBaseClientError.requestHasInvalidDelegate(
                    request: subscription,
                    delegate: subscription.delegate
                )
            )
            return
        }

        subscriptionDelegate.task = task
        subscriptionDelegate.requestCleanup = self.subscriptionSessionDelegate.removeRequestPairedWithTaskId

        // Pass through logger where required
        subscriptionDelegate.logger = self.logger

        subscriptionDelegate.heartbeatTimeout = Double(self.heartbeatTimeout)
        subscriptionDelegate.onOpening = onOpening
        subscriptionDelegate.onOpen = onOpen
        subscriptionDelegate.onEvent = onEvent
        subscriptionDelegate.onEnd = onEnd
        subscriptionDelegate.onError = onError

        task.resume()
    }

    public func subscribeWithResume(
        with resumableSubscription: inout PPResumableSubscription,
        using requestOptions: PPRequestOptions,
        instance: Instance,
        onOpening: (() -> Void)? = nil,
        onOpen: (() -> Void)? = nil,
        onResuming: (() -> Void)? = nil,
        onEvent: ((String, [String: String], Any) -> Void)? = nil,
        onEnd: ((Int?, [String: String]?, Any?) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        var mutableURLComponents = self.baseUrlComponents
        mutableURLComponents.queryItems = requestOptions.queryItems

        self.logger?.log(
            "URLComponents for subscribeWithResume in base client: \(mutableURLComponents.debugDescription)",
            logLevel: .verbose
        )

        guard var url = mutableURLComponents.url else {
            onError?(PPBaseClientError.invalidURL(components: mutableURLComponents))
            return
        }

        url = url.appendingPathComponent(requestOptions.path)

        self.logger?.log("URL for subscribeWithResume in base client: \(url)", logLevel: .verbose)

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.SUBSCRIBE.rawValue
        request.timeoutInterval = REALLY_LONG_TIME

        for (header, value) in requestOptions.headers {
            request.addValue(value, forHTTPHeaderField: header)
        }

        let task: URLSessionDataTask = self.subscriptionURLSession.dataTask(with: request)

        guard self.subscriptionSessionDelegate[task] == nil else {
            onError?(PPBaseClientError.preExistingTaskIdentifierForRequest)
            return
        }

        let subscription = PPRequest(type: .subscription)

        subscription.options = requestOptions

        self.subscriptionSessionDelegate[task] = subscription

        guard let subscriptionDelegate = subscription.delegate as? PPSubscriptionDelegate else {
            onError?(
                PPBaseClientError.requestHasInvalidDelegate(
                    request: subscription,
                    delegate: subscription.delegate
                )
            )
            return
        }

        subscriptionDelegate.requestCleanup = self.subscriptionSessionDelegate.removeRequestPairedWithTaskId
        subscriptionDelegate.task = task
        subscriptionDelegate.heartbeatTimeout = Double(self.heartbeatTimeout)

        // Retry strategy from PPRequestOptions takes precedent, otherwise falls back to the
        // PPRetryStrategy set in the BaseClient, which is PPDefaultRetryStrategy, unless
        // explicitly set to something else
        if let reqOptionsRetryStrategy = requestOptions.retryStrategy {
            resumableSubscription.retryStrategy = reqOptionsRetryStrategy
        } else {
            resumableSubscription.retryStrategy = self.retryStrategyBuilder(requestOptions)
        }

        resumableSubscription.subscription = subscription
        resumableSubscription.onOpening = onOpening
        resumableSubscription.onOpen = onOpen
        resumableSubscription.onResuming = onResuming
        resumableSubscription.onEvent = onEvent
        resumableSubscription.onEnd = onEnd
        resumableSubscription.onError = onError

        // Pass through logger where required
        subscriptionDelegate.logger = self.logger
        (resumableSubscription.retryStrategy as? PPDefaultRetryStrategy)?.logger = self.logger

        task.resume()
    }

    // TODO: Maybe need the same for cancelling general requests?

    // TODO: Look at this

    public func unsubscribe(taskIdentifier: Int, completionHandler: ((Error?) -> Void)? = nil) -> Void {
        self.subscriptionURLSession.getAllTasks { tasks in
            guard tasks.count > 0 else {
                completionHandler?(
                    PPBaseClientError.noTasksForSubscriptionURLSession(self.subscriptionURLSession)
                )
                return
            }

            let filteredTasks = tasks.filter { $0.taskIdentifier == taskIdentifier }

            guard filteredTasks.count == 1 else {
                completionHandler?(
                    PPBaseClientError.noTaskWithMatchingTaskIdentifierFound(
                        taskId: taskIdentifier,
                        session: self.subscriptionURLSession
                    )
                )
                return
            }

            filteredTasks.first!.cancel()
            completionHandler?(nil)
        }
    }

    static public func methodAwareRetryStrategyGenerator(requestOptions: PPRequestOptions) -> PPRetryStrategy {
        if let httpMethod = HTTPMethod(rawValue: requestOptions.method) {
            switch httpMethod {
            case .POST, .PUT, .PATCH:
                return PPDefaultRetryStrategy(maxNumberOfAttempts: 1)
            default:
                break
            }
        }
        return PPDefaultRetryStrategy()
    }
}

internal enum PPBaseClientError: Error {
    case invalidURL(components: URLComponents)
    case preExistingTaskIdentifierForRequest
    case noTasksForSubscriptionURLSession(URLSession)
    case noTaskWithMatchingTaskIdentifierFound(taskId: Int, session: URLSession)
    case requestHasInvalidDelegate(request: PPRequest, delegate: PPRequestTaskDelegate)
}

extension PPBaseClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let components):
            return "Invalid URL from components: \(components.debugDescription)"
        case .preExistingTaskIdentifierForRequest:
            return "Task identifier already in use for another request"
        case .noTasksForSubscriptionURLSession(let urlSession):
            return "No tasks for URLSession: \(urlSession.debugDescription)"
        case .noTaskWithMatchingTaskIdentifierFound(let taskId, let urlSession):
            return "No task with id \(taskId) for URLSession: \(urlSession.debugDescription)"
        case .requestHasInvalidDelegate(let request, let delegate):
            return "Request of type \(request.type.rawValue) has delegate of type \(type(of: delegate))"
        }
    }
}

public enum HTTPMethod: String {
    case POST
    case GET
    case PUT
    case DELETE
    case OPTIONS
    case PATCH
    case HEAD
    case SUBSCRIBE
}
