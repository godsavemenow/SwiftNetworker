import Foundation

/// A structure representing a network request.
public struct NetworkRequest {
    /// The URL for the network request.
    public let url: URL
    
    /// The HTTP method for the network request.
    public let method: HTTPMethod
    
    /// The headers for the network request.
    public let headers: [String: String]?
    
    /// The body for the network request.
    public let body: Data?
    
    /// Initializes a new instance of `NetworkRequest`.
    ///
    /// - Parameters:
    ///   - url: The URL for the network request.
    ///   - method: The HTTP method for the network request.
    ///   - headers: The headers for the network request. Default is nil.
    ///   - body: The body for the network request. Default is nil.
    public init(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}
