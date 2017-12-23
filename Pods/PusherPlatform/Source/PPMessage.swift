import Foundation

internal enum PPMessage {
    case keepAlive
    case event(eventId: String, headers: [String: String], body: Any)
    case eos(statusCode: Int, headers: [String: String], errorBody: Any)
}
