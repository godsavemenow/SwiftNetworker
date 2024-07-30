import Foundation

/// A structure representing a network request.
///
/// ## Overview
/// The `NetworkRequest` struct encapsulates all the necessary information required to make a network request.
/// This includes the URL, HTTP method, headers, and body of the request. The struct provides a simple and
/// consistent way to define network requests, which can be used by network handling classes such as `Networker`.
///
/// This struct helps in organizing and managing the details of a network request in a clear and concise manner,
/// making it easier to handle different types of requests (GET, POST, PUT, etc.) with optional headers and body data.
///
/// ## Usage
/// To use the `NetworkRequest`, create an instance of the struct by providing the URL, HTTP method, and optionally,
/// headers and body data. This instance can then be passed to network handling functions or classes.
///
/// ```swift
/// let url = URL(string: "https://example.com/api/resource")!
/// let headers = ["Content-Type": "application/json"]
/// let bodyData = "{\"key\":\"value\"}".data(using: .utf8)
/// let request = NetworkRequest(url: url, method: .post, headers: headers, body: bodyData)
/// ```
public struct NetworkRequest {
    /// The URL for the network request.
    public var url: URL?
    
    /// The HTTP method for the network request.
    public let method: HTTPMethod
    
    /// The headers for the network request.
    public let headers: [String: String]?
    
    /// The body for the network request.
    public var bodyData: Data? {
        do {
            guard let body = body else {
                return nil
            }
            return try JSONEncoder().encode(body)
        } catch {
            return nil
        }
    }
    
    public let body: Encodable?
    
    /// Initializes a new instance of `NetworkRequest` with a URL string.
    ///
    /// - Parameters:
    ///   - urlString: The URL string for the network request.
    ///   - method: The HTTP method for the network request.
    ///   - headers: The headers for the network request. Default is nil.
    ///   - body: The body for the network request. Default is nil.
    public init(urlString: String, method: HTTPMethod, headers: [String: String]? = nil, body: Encodable? = nil) {
        self.url = URL(string: urlString)
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    /// Initializes a new instance of `NetworkRequest` with a URL.
    ///
    /// - Parameters:
    ///   - url: The URL for the network request.
    ///   - method: The HTTP method for the network request.
    ///   - headers: The headers for the network request. Default is nil.
    ///   - body: The body for the network request. Default is nil.
    public init(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: Encodable? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}
