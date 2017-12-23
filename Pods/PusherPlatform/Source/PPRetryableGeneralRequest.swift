import Foundation

// TODO: Rename, maybe?

@objc public class PPRetryableGeneralRequest: NSObject {
    public let requestOptions: PPRequestOptions
    public internal(set) var instance: Instance
    public internal(set) var generalRequest: PPRequest? = nil
    public var retryStrategy: PPRetryStrategy? = nil
    internal var retryRequestTimer: Timer? = nil

    public var onSuccess: ((Data) -> Void)? {
        willSet {
            guard let generalRequestDelegate = self.generalRequest?.delegate as? PPGeneralRequestDelegate else {
                self.instance.logger.log(
                    "Invalid delegate for general request: \(String(describing: self.generalRequest))",
                    logLevel: .error
                )
                return
            }

            // TODO: Not using a weak self here because a request, unlike a subscription,
            // is notexpected to be referenced and stored for its lifecycle, so we do in
            // fact want to capture self here - this isn't ideal though, so we need a
            // better way of handling with cleanup. Could just be a function that gets
            // called after success / error and sets the onSuccess and onError closures
            // on the delegate to be nil so that the references to this are gone
            generalRequestDelegate.onSuccess = { data in
                self.handleOnSuccess(data)
                newValue?(data)
            }
        }
    }

    internal var _onError: ((Error) -> Void)? = nil

    public var onError: ((Error) -> Void)? {
        willSet {
            guard let generalRequestDelegate = self.generalRequest?.delegate as? PPGeneralRequestDelegate else {
                self.instance.logger.log(
                    "Invalid delegate for general request: \(String(describing: self.generalRequest))",
                    logLevel: .error
                )
                return
            }

            // TODO: Not using a weak self here because a request, unlike a subscription,
            // is notexpected to be referenced and stored for its lifecycle, so we do in
            // fact want to capture self here - this isn't ideal though, so we need a
            // better way of handling with cleanup. Could just be a function that gets
            // called after success / error and sets the onSuccess and onError closures
            // on the delegate to be nil so that the references to this are gone
            generalRequestDelegate.onError = { error in
                self.handleOnError(error: error)
            }

            self._onError = newValue
        }
    }

    public init(instance: Instance, requestOptions: PPRequestOptions) {
        self.instance = instance
        self.requestOptions = requestOptions
    }

    deinit {
        self.retryRequestTimer?.invalidate()
    }

    // TODO: Is this necessary in general?
    public func handleOnSuccess(_ data: Data) {}

    public func handleOnError(error: Error) {
//        TODO: Do we need something like this?

//        guard !self.cancelled else {
//            // TODO: Really? Does this make sense?
//            self.changeState(to: .ended)
//            return
//        }

        guard let retryStrategy = self.retryStrategy else {
            self.instance.logger.log("Not attempting retry because no retry strategy is set", logLevel: .debug)
            self._onError?(PPRetryableError.noRetryStrategyProvided)
            return
        }

//         TODO: Check which errors to pass to RetryStrategy

        self.retryRequestTimer?.invalidate()

        let shouldRetryResult = retryStrategy.shouldRetry(given: error)

        switch shouldRetryResult {
        case .retry(let retryWaitTimeInterval):
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    print("self is nil when setting up retry subscription timer")
                    return
                }

                strongSelf.retryRequestTimer = Timer.scheduledTimer(
                    timeInterval: retryWaitTimeInterval,
                    target: strongSelf,
                    selector: #selector(strongSelf.retryRequest),
                    userInfo: nil,
                    repeats: false
                )
            }
        case .doNotRetry(let reasonErr):
            self._onError?(reasonErr)
        }
    }

    @objc internal func retryRequest() {
        guard let generalRequestDelegate = self.generalRequest?.delegate as? PPGeneralRequestDelegate else {
            self.instance.logger.log(
                "Invalid delegate for general request: \(String(describing: self.generalRequest))",
                logLevel: .error
            )
            return
        }

        self.instance.logger.log("Cancelling subscriptionDelegate's existing task", logLevel: .verbose)
        generalRequestDelegate.task?.cancel()

        self.instance.logger.log("Creating new underlying request for retrying", logLevel: .debug)

        let newRequest = self.instance.request(
            using: self.requestOptions,
            onSuccess: generalRequestDelegate.onSuccess,
            onError: generalRequestDelegate.onError
        )

        self.generalRequest = newRequest
    }
}
