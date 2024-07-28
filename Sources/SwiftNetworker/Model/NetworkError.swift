import Foundation

public struct NetworkError: Error {
    let errorCase: NetworkErrorCases
    let apiErrorMessage: String?
    
    public var detailedDescription: String {
        if let apiErrorMessage = apiErrorMessage {
            return "\(errorCase.description) - \(apiErrorMessage)"
        } else {
            return errorCase.description
        }
    }
}

/// An enumeration representing various types of network-related errors.
public enum NetworkErrorCases: CustomStringConvertible {
    case invalidURL
    case noData
    case timeOut
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case serverError(String)
    case parsingError(String)
    case requestCanceled(String)
    case decodingError(String)
    case networkError(Error)
    case unknown(Error)
    case multipleChoices(String)
    case movedPermanently(String)
    case found(String)
    case seeOther(String)
    case notModified(String)
    case useProxy(String)
    case temporaryRedirect(String)
    case permanentRedirect(String)

    /// Provides a textual description of the error.
    public var description: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noData:
            return "No data was returned from the server."
        case .timeOut:
            return "The request timed out."
        case .badRequest(let message):
            return "Bad Request: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .forbidden(let message):
            return "Forbidden: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .parsingError(let message):
            return "Parsing Error: \(message)"
        case .requestCanceled(let message):
            return "Request Canceled: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"
        case .multipleChoices(let message):
            return "Multiple Choices: \(message)"
        case .movedPermanently(let message):
            return "Moved Permanently: \(message)"
        case .found(let message):
            return "Found: \(message)"
        case .seeOther(let message):
            return "See Other: \(message)"
        case .notModified(let message):
            return "Not Modified: \(message)"
        case .useProxy(let message):
            return "Use Proxy: \(message)"
        case .temporaryRedirect(let message):
            return "Temporary Redirect: \(message)"
        case .permanentRedirect(let message):
            return "Permanent Redirect: \(message)"
        }
    }
}