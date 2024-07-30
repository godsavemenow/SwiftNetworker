import Foundation

/// A structure representing the response from a network request.
///
/// ## Overview
/// The `NetworkResponse` struct encapsulates the data and response information returned from a network request.
/// This includes the raw data received from the server and the associated `URLResponse` object. The struct provides
/// a simple and consistent way to represent the results of a network operation, making it easier to handle and process
/// the response data and metadata.
///
/// This struct is typically used in network handling code where the results of network requests need to be managed
/// and interpreted. It allows developers to access both the raw response data and the details of the HTTP response.
///
/// ## Usage
/// To use the `NetworkResponse`, create an instance by providing the data and response received from a network request.
/// This instance can then be used to access the raw response data and the metadata of the response.
///
/// ```swift
/// let data: Data = ...
/// let urlResponse: URLResponse = ...
/// let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
/// ```
///
/// ## Properties
public class NetworkResponse {
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
