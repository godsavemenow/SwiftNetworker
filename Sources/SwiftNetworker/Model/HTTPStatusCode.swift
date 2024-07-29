import Foundation

/// An enumeration representing HTTP status codes.
///
/// ## Overview
/// The `HTTPStatusCode` enumeration defines a comprehensive list of HTTP status codes categorized into success, redirection,
/// client error, and server error responses. Each case in this enumeration represents a specific HTTP status code and its associated
/// integer value. The enumeration also provides utility methods to check the category of a given status code and to create an instance
/// from an integer value.
///
/// This enumeration is useful for handling and interpreting HTTP responses in network operations, allowing developers to easily
/// identify the type of response and take appropriate action based on the status code.
///
/// ## Usage
/// To use the `HTTPStatusCode` enumeration, either match against specific cases or use the utility methods to check the category of
/// a status code. For example:
///
/// ```swift
/// if HTTPStatusCode.isSuccessful(response.statusCode) {
///     // Handle successful response
/// } else if HTTPStatusCode.isClientError(response.statusCode) {
///     // Handle client error response
/// }
/// ```
///
/// ## Cases
public enum HTTPStatusCode: Int {
    // 2xx Success
    /// The request has succeeded.
    case ok = 200
    /// The request has been fulfilled and resulted in a new resource being created.
    case created = 201
    /// The request has been accepted for processing, but the processing has not been completed.
    case accepted = 202
    /// The server successfully processed the request and is not returning any content.
    case noContent = 204
    
    // 3xx Redirection
    /// Indicates multiple options for the resource that the client may follow.
    case multipleChoices = 300
    /// This and all future requests should be directed to the given URI.
    case movedPermanently = 301
    /// The resource was found at another URI.
    case found = 302
    /// The response to the request can be found under another URI.
    case seeOther = 303
    /// Indicates that the resource has not been modified since the version specified by the request headers.
    case notModified = 304
    /// The requested resource is only available through a proxy.
    case useProxy = 305
    /// The resource resides temporarily under a different URI.
    case temporaryRedirect = 307
    /// The resource resides permanently under a different URI.
    case permanentRedirect = 308
    
    // 4xx Client Error
    /// The server could not understand the request due to invalid syntax.
    case badRequest = 400
    /// The client must authenticate itself to get the requested response.
    case unauthorized = 401
    /// The client does not have access rights to the content.
    case forbidden = 403
    /// The server can not find the requested resource.
    case notFound = 404
    
    // 5xx Server Error
    /// The server has encountered a situation it does not know how to handle.
    case internalServerError = 500
    /// The request method is not supported by the server and cannot be handled.
    case notImplemented = 501
    /// The server, while acting as a gateway or proxy, received an invalid response from the upstream server.
    case badGateway = 502
    /// The server is not ready to handle the request.
    case serviceUnavailable = 503
    
    // MARK: - Utility Methods

    /// Checks if the status code indicates a successful response (2xx).
    ///
    /// - Parameter statusCode: The status code to check.
    /// - Returns: `true` if the status code indicates a successful response, otherwise `false`.
    static func isSuccessful(_ statusCode: Int) -> Bool {
        return (200...299).contains(statusCode)
    }
    
    /// Checks if the status code indicates a redirection (3xx).
    ///
    /// - Parameter statusCode: The status code to check.
    /// - Returns: `true` if the status code indicates a redirection, otherwise `false`.
    static func isRedirection(_ statusCode: Int) -> Bool {
        return (300...399).contains(statusCode)
    }
    
    /// Checks if the status code indicates a client error (4xx).
    ///
    /// - Parameter statusCode: The status code to check.
    /// - Returns: `true` if the status code indicates a client error, otherwise `false`.
    static func isClientError(_ statusCode: Int) -> Bool {
        return (400...499).contains(statusCode)
    }

    /// Checks if the status code indicates a server error (5xx).
    ///
    /// - Parameter statusCode: The status code to check.
    /// - Returns: `true` if the status code indicates a server error, otherwise `false`.
    static func isServerError(_ statusCode: Int) -> Bool {
        return (500...599).contains(statusCode)
    }

    /// Creates an `HTTPStatusCode` from an integer value.
    ///
    /// - Parameter statusCode: The integer value representing the status code.
    /// - Returns: An optional `HTTPStatusCode` corresponding to the given integer value.
    static func from(_ statusCode: Int) -> HTTPStatusCode? {
        return HTTPStatusCode(rawValue: statusCode)
    }
}
