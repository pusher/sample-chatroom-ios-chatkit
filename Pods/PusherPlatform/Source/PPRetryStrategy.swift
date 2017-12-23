import Foundation

public protocol PPRetryStrategy {
    func shouldRetry(given: Error) -> PPRetryStrategyResult
    func requestSucceeded()
}

extension PPRetryStrategy {
    public func requestSucceeded() {}
}

public enum PPRetryStrategyResult {
    case retry(after: TimeInterval)
    case doNotRetry(reason: Error)
}
