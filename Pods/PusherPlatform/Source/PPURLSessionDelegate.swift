import Foundation

public class PPURLSessionDelegate: NSObject {
    public let insecure: Bool
    internal let sessionQueue: DispatchQueue
    public var logger: PPLogger? = nil {
        willSet {
            // TODO: Do we want to set the logger on the requests' delegates here?

            self.requests.forEach { (arg) in
                
                let (_, req) = arg
                req.setLoggerOnDelegate(newValue)
            }
        }
    }

    public var requests: [Int: PPRequest] = [:]
    private let lock = NSLock()

    open subscript(task: URLSessionTask) -> PPRequest? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return requests[task.taskIdentifier]
        }

        set {
            lock.lock()
            defer { lock.unlock() }
            requests[task.taskIdentifier] = newValue
        }
    }

    public func removeRequestPairedWithTaskId(_ taskId: Int) {
        lock.lock()
        defer { lock.unlock() }
        requests.removeValue(forKey: taskId)
    }

    public init(insecure: Bool) {
        self.insecure = insecure
        self.sessionQueue = DispatchQueue(label: "com.pusherplatform.swift.ppsessiondelegate.\(NSUUID().uuidString)")
    }

}

extension PPURLSessionDelegate: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.logger?.log("Session became invalid: \(session)", logLevel: .error)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        sessionQueue.async {
            guard let request = self[task] else {
                guard let error = error else {
                    self.logger?.log(
                        "No request found paired with taskIdentifier \(task.taskIdentifier), which encountered an unknown error",
                        logLevel: .debug
                    )
                    return
                }

                if (error as NSError).code == NSURLErrorCancelled {
                    self.logger?.log(
                        "No request found paried with taskIdentifier \(task.taskIdentifier) as request was cancelled; likely due to an explicit call to end it, or a heartbeat timeout",
                         logLevel: .debug
                    )
                } else {
                    self.logger?.log(
                        "No request found paired with taskIdentifier \(task.taskIdentifier), which encountered error: \(error.localizedDescription))",
                        logLevel: .debug
                    )
                }

                return
            }

            request.delegate.handleCompletion(error: error)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        sessionQueue.async {
            guard let request = self[dataTask] else {
                self.logger?.log(
                    "No request found paired with taskIdentifier \(dataTask.taskIdentifier), which received response: \(response)",
                    logLevel: .debug
                )
                completionHandler(.cancel)
                return
            }

            request.delegate.handle(response, completionHandler: completionHandler)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        sessionQueue.async {
            guard let request = self[dataTask] else {
                self.logger?.log(
                    "No request found paired with taskIdentifier \(dataTask.taskIdentifier), which received some data",
                    logLevel: .debug
                )
                return
            }

            request.delegate.handle(data)
        }
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        if self.insecure {
            let allowAllCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, allowAllCredential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

}
