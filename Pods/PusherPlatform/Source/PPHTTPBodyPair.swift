import Foundation

public typealias PPHTTPBody = [PPHTTPBodyPair]

public struct PPHTTPBodyPair {
    let key: String
    let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public static func queryString(body: PPHTTPBody) -> String {
        return body.map ({ (pair) in
            "\(pair.key)=\(pair.value)"
        }).joined(separator: "&")
    }
}
