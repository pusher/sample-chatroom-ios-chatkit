import Foundation

public protocol PPTokenProvider {
    func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void)
}

public enum PPTokenProviderResult {
    case success(token: String)
    case error(error: Error)
}
