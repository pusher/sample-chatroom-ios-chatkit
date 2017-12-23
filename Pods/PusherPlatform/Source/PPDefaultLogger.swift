import Foundation

public class PPDefaultLogger {
    public var minimumLogLevel: PPLogLevel = .debug
    internal let logQueue = DispatchQueue(label: "com.pusherplatform.swift.defaultlogger")

    public init() {}
}

extension PPDefaultLogger: PPLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PPLogLevel) {
        if logLevel >= minimumLogLevel {
            logQueue.async {
                print("[\(logLevel.stringRepresentation())] \(message())")
            }
        }
    }
}
