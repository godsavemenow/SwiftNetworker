import Foundation

/// A structure representing a response from a network request.
public struct Response<T: Decodable> {
    /// The complete network response.
    public let networkResponse: NetworkResponse
    
    /// The decoded response.
    public let decodedResponse: T
    
    /// Initializes a new instance of `Response`.
    ///
    /// - Parameters:
    ///   - networkResponse: The complete network response.
    ///   - decodedResponse: The decoded response.
    public init(networkResponse: NetworkResponse, decodedResponse: T) {
        self.networkResponse = networkResponse
        self.decodedResponse = decodedResponse
    }
}
