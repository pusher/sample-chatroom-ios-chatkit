import Foundation

public class PPDefaultRetryStrategy: PPRetryStrategy {

    public var maxNumberOfAttempts: Int?
    public var maxTimeIntervalBetweenAttempts: TimeInterval?

    public internal(set) var numberOfAttempts: Int = 0

    public var logger: PPLogger? = nil

    public init(maxNumberOfAttempts: Int = 6, maxTimeIntervalBetweenAttempts: TimeInterval? = nil) {
        self.maxNumberOfAttempts = maxNumberOfAttempts
        self.maxTimeIntervalBetweenAttempts = maxTimeIntervalBetweenAttempts
    }

    public func requestSucceeded() {
        self.numberOfAttempts = 0
    }

    public func shouldRetry(given error: Error) -> PPRetryStrategyResult {
        self.numberOfAttempts += 1

        guard self.maxNumberOfAttempts != nil && self.numberOfAttempts < self.maxNumberOfAttempts! else {
            self.logger?.log(
                "Maximum number of attempts (\(self.maxNumberOfAttempts!)) made. Latest error: \(error.localizedDescription)",
                logLevel: .debug
            )
            return PPRetryStrategyResult.doNotRetry(
                reason: PPDefaultRetryStrategyError.maximumNumberOfAttemptsMade(latestErrorReceived: error)
            )
        }

        let timeIntervalBeforeNextAttempt = TimeInterval(self.numberOfAttempts * self.numberOfAttempts)

        let timeBeforeNextAttempt = self.maxTimeIntervalBetweenAttempts != nil
                                  ? min(timeIntervalBeforeNextAttempt, self.maxTimeIntervalBetweenAttempts!)
                                  : timeIntervalBeforeNextAttempt

        if self.maxNumberOfAttempts != nil {
            self.logger?.log(
                "Making attempt \(self.numberOfAttempts + 1) of \(self.maxNumberOfAttempts!) in \(timeBeforeNextAttempt)s. Error was: \(error.localizedDescription)",
                logLevel: .debug
            )
        } else {
            self.logger?.log(
                "Making attempt \(self.numberOfAttempts + 1) in \(timeBeforeNextAttempt)s. Error was: \(error.localizedDescription)",
                logLevel: .debug
            )
        }

        return PPRetryStrategyResult.retry(after: timeBeforeNextAttempt)
    }

}

public enum PPDefaultRetryStrategyError: Error {
    case maximumNumberOfAttemptsMade(latestErrorReceived: Error)
}

extension PPDefaultRetryStrategyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .maximumNumberOfAttemptsMade(let latestErrorReceived):
            return "Maximum number of attempts made. The last error receieved was: \(latestErrorReceived.localizedDescription)"
        }
    }
}
