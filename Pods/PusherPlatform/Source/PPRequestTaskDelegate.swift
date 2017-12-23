import Foundation

internal protocol PPRequestTaskDelegate {
    var data: Data { get set }
    var task: URLSessionDataTask? { get set }
    var error: Error? { get set }
    var logger: PPLogger? { get set }

    // If there's a bad response status code then we need to wait for
    // data to be received before communicating the error to the handler
    var badResponse: HTTPURLResponse? { get set }

    var badResponseError: Error? { get set }

    // TODO: Is this necessary or will we always receive data on error?
//    var waitForDataAccompanyingBadStatusCodeResponseTimer: Timer? { get set }

    init(task: URLSessionDataTask?)

    func handle(_ response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void)
    func handle(_ data: Data)
    func handleCompletion(error: Error?)
}


public enum PPRequestTaskDelegateError: Error {
    case invalidHTTPResponse(response: URLResponse)
    case badResponseStatusCode(response: HTTPURLResponse)
    case badResponseStatusCodeWithMessage(response: HTTPURLResponse, errorMessage: String)
}

extension PPRequestTaskDelegateError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidHTTPResponse(let response):
            return "Invalid HTTP response received: \(response.debugDescription)"
        case .badResponseStatusCode(let response):
            return "Bad response status code received: \(response.statusCode)"
        case .badResponseStatusCodeWithMessage(let response, let errorMessage):
            return "Bad response status code received: \(response.statusCode) with error message: \(errorMessage)"
        }
    }
}
