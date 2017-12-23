import Foundation

public class PPRequest {

    let type: PPRequestType
    var delegate: PPRequestTaskDelegate

    // TODO: Should this be Optional? Who should be able to set options?

    public var options: PPRequestOptions? = nil

    // TODO: Fix this - this is just wrong. It should only live on a PPSubscription
    // sort of object

//    public internal(set) var state: SubscriptionState = .opening


    // TODO: Should this be public?
    init(type: PPRequestType, delegate: PPRequestTaskDelegate? = nil) {
        self.type = type
        switch type {
        case .subscription:
            self.delegate = delegate ?? PPSubscriptionDelegate()
        case .general:
            self.delegate = delegate ?? PPGeneralRequestDelegate()
        }
    }

    func setLoggerOnDelegate(_ logger: PPLogger?) {
        self.delegate.logger = logger
    }

}

extension PPRequest: CustomDebugStringConvertible {
    public var debugDescription: String {
        let requestInfo = "Request type: \(self.type.rawValue)"
        return [requestInfo, self.options.debugDescription].joined(separator: "\n")
    }
}


public enum PPRequestType: String {
    case subscription
    case general
}
