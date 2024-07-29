import Foundation

/// A structure representing a response from a network request.
///
/// ## Overview
/// The `Response` struct encapsulates both the complete network response and the decoded response data.
/// It is a generic struct that works with any type conforming to the `Decodable` protocol. This struct
/// allows developers to access both the raw network response and the parsed, type-safe response data
/// in a single, convenient object.
///
/// This struct is particularly useful in network handling code where the response data needs to be
/// decoded into a specific model type. By combining the raw response and the decoded response, it
/// facilitates easier error handling and data processing.
///
/// ## Usage
/// To use the `Response` struct, create an instance by providing the `NetworkResponse` and the decoded
/// response data. This instance can then be used to access both the raw network response and the parsed
/// response data.
///
/// ```swift
/// let networkResponse = NetworkResponse(data: responseData, URLResponse: urlResponse)
/// let decodedResponse: MyModel = try JSONDecoder().decode(MyModel.self, from: responseData)
/// let response = Response(networkResponse: networkResponse, decodedResponse: decodedResponse)
/// ```
///
/// ## Properties
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
