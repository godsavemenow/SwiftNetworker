import Foundation

/// A protocol defining the contract for error handling.
protocol ErrorHandlerable {
    /// Handles an error and its associated URL response, returning a `NetworkError`.
    ///
    /// - Parameters:
    ///   - error: The error to handle.
    ///   - response: The URL response associated with the error.
    /// - Returns: A `NetworkError` representing the handled error.
    func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError
}

/// A class responsible for handling various types of errors and converting them into `NetworkError` instances.
public class ErrorHandler: ErrorHandlerable {
    
    /// Initializes a new instance of `ErrorHandler`.
    public init() {}
    
    
    /// Handles an error and its associated URL response, returning a `NetworkError`.
    ///
    /// - Parameters:
    ///   - error: The error to handle.
    ///   - response: The URL response associated with the error.
    /// - Returns: A `NetworkError` representing the handled error.
    public func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError {
        
        if let httpResponse = response as? HTTPURLResponse {
            if HTTPStatusCode.isClientError(httpResponse.statusCode) {
                return createNetworkError(data: data, errorCase: handleClientError(httpResponse.statusCode))
            } else if HTTPStatusCode.isServerError(httpResponse.statusCode) {
                return createNetworkError(data: data, errorCase: handleServerError(httpResponse.statusCode))
            } else if HTTPStatusCode.isRedirection(httpResponse.statusCode) {
                return createNetworkError(data: data, errorCase: handleRedirectionError(httpResponse.statusCode))
            }
        }
        
        switch error {
        case let decodingError as DecodingError:
            return createNetworkError(data: data, errorCase: handleDecodingError(decodingError))
        case let urlError as URLError:
            return createNetworkError(data: data, errorCase: handleURLError(urlError))
        default:
            return createNetworkError(data: data, errorCase: handleUnknownError(error))
        }
    }
    
    /// Handles a `DecodingError` and returns a corresponding `NetworkError`.
    ///
    /// - Parameter error: The `DecodingError` to handle.
    /// - Returns: A `NetworkError` representing the decoding error.
    private func handleDecodingError(_ error: DecodingError) -> NetworkErrorCases {
        switch error {
        case .dataCorrupted(let context):
            return .decodingError("Data corrupted: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            return .decodingError("Key '\(key.stringValue)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
        case .typeMismatch(let type, let context):
            return .decodingError("Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)")
        case .valueNotFound(let value, let context):
            return .decodingError("Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
        @unknown default:
            return .unknown(error)
        }
    }
    
    /// Handles a `URLError` and returns a corresponding `NetworkError`.
    ///
    /// - Parameter error: The `URLError` to handle.
    /// - Returns: A `NetworkError` representing the URL error.
    private func handleURLError(_ error: URLError) -> NetworkErrorCases {
        switch error.code {
        case .timedOut:
            return .timeOut
        case .cannotFindHost, .cannotConnectToHost, .unsupportedURL, .badURL:
            return .invalidURL
        case .cancelled:
            return .requestCanceled("The request was canceled.")
        default:
            return .networkError(error)
        }
    }
    
    func createNetworkError(data: Data?, errorCase: NetworkErrorCases) -> NetworkError {
        let apiErrorMessage = data.flatMap { String(data: $0, encoding: .utf8) }
        return NetworkError(errorCase: errorCase, apiErrorMessage: apiErrorMessage)
    }
    
    /// Handles an unknown error, returning a corresponding `NetworkError`.
    ///
    /// - Parameter error: The unknown error to handle.
    /// - Returns: A `NetworkError` representing the unknown error.
    private func handleUnknownError(_ error: Error?) -> NetworkErrorCases {
        if let error = error {
            return .unknown(error)
        } else {
            return .unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."]))
        }
    }
    
    /// Handles a client error (4xx status code) and returns a corresponding `NetworkError`.
    ///
    /// - Parameter statusCode: The HTTP status code to handle.
    /// - Returns: A `NetworkError` representing the client error.
    private func handleClientError(_ statusCode: Int) -> NetworkErrorCases {
        if let status = HTTPStatusCode.from(statusCode) {
            switch status {
            case .badRequest:
                return .badRequest("The request was malformed or contained invalid parameters.")
            case .unauthorized:
                return .unauthorized("Authentication is required and has failed or has not yet been provided.")
            case .forbidden:
                return .forbidden("The server understood the request but refuses to authorize it.")
            case .notFound:
                return .notFound("The requested resource could not be found.")
            default:
                return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Client error with status code \(statusCode)."]))
            }
        }
        return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Client error with status code \(statusCode)."]))
    }
    
    /// Handles a server error (5xx status code) and returns a corresponding `NetworkError`.
    ///
    /// - Parameter statusCode: The HTTP status code to handle.
    /// - Returns: A `NetworkError` representing the server error.
    private func handleServerError(_ statusCode: Int) -> NetworkErrorCases {
        if let status = HTTPStatusCode.from(statusCode) {
            switch status {
            case .internalServerError:
                return .serverError("The server encountered an internal error and was unable to complete your request.")
            case .notImplemented:
                return .serverError("The server does not support the functionality required to fulfill the request.")
            case .badGateway:
                return .serverError("The server received an invalid response from the upstream server.")
            case .serviceUnavailable:
                return .serverError("The server is currently unable to handle the request due to temporary overload or maintenance.")
            default:
                return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code \(statusCode)."]))
            }
        }
        return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code \(statusCode)."]))
    }
    
    /// Handles a redirection (3xx status code) and returns a corresponding `NetworkError`.
    ///
    /// - Parameter statusCode: The HTTP status code to handle.
    /// - Returns: A `NetworkError` representing the redirection.
    private func handleRedirectionError(_ statusCode: Int) -> NetworkErrorCases {
        if let status = HTTPStatusCode.from(statusCode) {
            switch status {
            case .multipleChoices:
                return .multipleChoices("Multiple choices available.")
            case .movedPermanently:
                return .movedPermanently("The resource has been moved permanently.")
            case .found:
                return .found("The resource has been found at a different location.")
            case .seeOther:
                return .seeOther("See other resource.")
            case .notModified:
                return .notModified("The resource has not been modified.")
            case .useProxy:
                return .useProxy("The resource is accessible only through a proxy.")
            case .temporaryRedirect:
                return .temporaryRedirect("The resource is temporarily located at a different location.")
            case .permanentRedirect:
                return .permanentRedirect("The resource is permanently located at a different location.")
            default:
                return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Redirection with status code \(statusCode)."]))
            }
        }
        return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Redirection with status code \(statusCode)."]))
    }
}

