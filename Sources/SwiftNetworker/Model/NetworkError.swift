import Foundation

/// A custom error type representing various network-related errors.
///
/// ## Overview
/// The `NetworkError` struct provides a comprehensive way to handle and represent errors that occur during network operations.
/// It encapsulates various types of network errors through the `NetworkErrorCases` enumeration, allowing for detailed descriptions
/// and messages provided by APIs. The `NetworkError` struct combines these error cases with optional API messages to create a
/// detailed description of the error, facilitating easier debugging and error handling.
///
/// This struct is particularly useful in network-related code where different types of errors need to be handled uniformly. It
/// conforms to the `Error` protocol, making it compatible with Swift's error handling mechanisms.
///
/// ## Usage
/// To use the `NetworkError`, create an instance with a specific `NetworkErrorCases` value and an optional API error message.
/// Access the `detailedDescription` property to get a combined description of the error case and the API message.
///
/// ```swift
/// let error = NetworkError(errorCase: .badRequest("Invalid parameters"), apiErrorMessage: "Parameter 'id' is missing")
/// print(error.detailedDescription)  // Output: "Bad Request: Invalid parameters - Parameter 'id' is missing"
/// ```
///
/// ## Properties
public struct NetworkError: Error {
    /// The specific case of the network error.
    let errorCase: NetworkErrorCases
    /// An optional message provided by the API.
    let apiErrorMessage: String?
    
    /// A detailed description of the network error, combining the error case description and the API message if available.
    public var detailedDescription: String {
        if let apiErrorMessage = apiErrorMessage {
            return "\(errorCase.description) - \(apiErrorMessage)"
        } else {
            return errorCase.description
        }
    }
}
