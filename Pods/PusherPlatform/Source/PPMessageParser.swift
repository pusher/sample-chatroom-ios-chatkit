import Foundation

internal class PPMessageParser {
    internal var logger: PPLogger?

    init(logger: PPLogger?) {
        self.logger = logger
    }

    // Parse errors are truly unexpected here - we trust the server to give us good data
    internal func parse(stringMessages: [String]) -> [PPMessage] {
        return stringMessages.flatMap { stringMessage -> PPMessage? in
            guard stringMessage != "" else {
                return nil
            }

            guard let stringMessageData = stringMessage.data(using: .utf8) else {
                self.logger?.log(
                    "Failed to convert message String to Data: \(stringMessage)",
                    logLevel: .debug
                )
                return nil
            }

            guard let jsonObject = try? JSONSerialization.jsonObject(with: stringMessageData, options: []) else {
                self.logger?.log(
                    "Failed to deserialize received string to JSON object: \(stringMessage)",
                    logLevel: .debug
                )
                return nil
            }

            guard let jsonArray = jsonObject as? [Any] else {
                self.logger?.log(
                    "Failed to cast JSON object to Dictionary: \(jsonObject)",
                    logLevel: .debug
                )
                return nil
            }

            guard jsonArray.count != 0 else {
                self.logger?.log("Empty JSON array received", logLevel: .debug)
                return nil
            }

            guard let messageTypeCode = jsonArray[0] as? Int else {
                self.logger?.log("Received invalid message type code: \(jsonArray[0])", logLevel: .debug)
                return nil
            }

            guard let messageType = parseMessageTypeCode(messageTypeCode: messageTypeCode) else {
                self.logger?.log("Unknown message type code received: \(messageTypeCode)", logLevel: .debug)
                return nil
            }

            guard jsonArray.count == messageType.numberOfElements() else {
                self.logger?.log(
                    "Expected \(messageType.numberOfElements()) elements in message of type \(messageType.rawValue) but received \(jsonArray.count)",
                    logLevel: .debug
                )
                return nil
            }

            switch messageType {
            case .keepAlive:
                guard let _ = jsonArray[1] as? String else {
                    self.logger?.log("Received invalid keep-alive data: \(jsonArray[1])", logLevel: .debug)
                    return nil
                }

                return PPMessage.keepAlive

            case .event:
                guard let eventId = jsonArray[1] as? String else {
                    self.logger?.log("Received invalid event ID: \(jsonArray[1])", logLevel: .debug)
                    return nil
                }

                guard let headers = jsonArray[2] as? [String: String] else {
                    self.logger?.log("Received invalid headers: \(jsonArray[2])", logLevel: .debug)
                    return nil
                }

                let body = jsonArray[3]

                return PPMessage.event(eventId: eventId, headers: headers, body: body)

            case .eos:
                guard let statusCode = jsonArray[1] as? Int else {
                    self.logger?.log("Received invalid status code: \(jsonArray[1])", logLevel: .debug)
                    return nil
                }

                guard let headers = jsonArray[2] as? [String: String] else {
                    self.logger?.log("Received invalid headers: \(jsonArray[2])", logLevel: .debug)
                    return nil
                }

                let errorBody = jsonArray[3]

                return PPMessage.eos(statusCode: statusCode, headers: headers, errorBody: errorBody)
            }
        }
    }

    fileprivate func parseMessageTypeCode(messageTypeCode: Int) -> PPMessageType? {
        switch messageTypeCode {
        case 0: return .keepAlive
        case 1: return .event
        case 255: return .eos
        default: return nil
        }
    }

}

internal enum PPMessageType: String {
    case keepAlive
    case event
    case eos

    internal func numberOfElements() -> Int {
        switch self {
        case .keepAlive: return 2
        case .event: return 4
        case .eos: return 4
        }
    }
}
