import Foundation

/// A structure representing the response from a network request.
public struct NetworkResponse {
    /// The raw data returned from the network request.
    public let data: Data
    
    /// The URL response returned from the network request.
    public let URLResponse: URLResponse
    
    /// Initializes a new instance of `NetworkResponse`.
    ///
    /// - Parameters:
    ///   - data: The raw data returned from the network request.
    ///   - URLResponse: The URL response returned from the network request.
    public init(data: Data, URLResponse: URLResponse) {
        self.data = data
        self.URLResponse = URLResponse
    }
}
