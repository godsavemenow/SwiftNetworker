import Foundation

enum HTTPStatusCode: Int {
    // 2xx Success
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    
    // 3xx Redirection
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case temporaryRedirect = 307
    case permanentRedirect = 308
    
    // 4xx Client Error
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    
    // 5xx Server Error
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503

    
    /// Checks if the status code indicates a redirection (3xx).
    static func isSuccessful(_ statusCode: Int) -> Bool {
        return (200...299).contains(statusCode)
    }
    
    /// Checks if the status code indicates a redirection (3xx).
    static func isRedirection(_ statusCode: Int) -> Bool {
        return (300...399).contains(statusCode)
    }
    
    /// Checks if the status code indicates a client error (4xx).
    static func isClientError(_ statusCode: Int) -> Bool {
        return (400...499).contains(statusCode)
    }

    /// Checks if the status code indicates a server error (5xx).
    static func isServerError(_ statusCode: Int) -> Bool {
        return (500...599).contains(statusCode)
    }

    /// Creates an HTTPStatusCode from an integer value.
    static func from(_ statusCode: Int) -> HTTPStatusCode? {
        return HTTPStatusCode(rawValue: statusCode)
    }
}
