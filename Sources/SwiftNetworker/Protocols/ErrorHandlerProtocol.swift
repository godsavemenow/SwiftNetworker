import Foundation

/// A protocol defining the contract for error handling.
///
/// ## Overview
/// The `ErrorHandlerProtocol` provides a standardized interface for handling errors that occur during network operations.
/// Implementing this protocol allows for custom error processing logic to be encapsulated within conforming types,
/// ensuring consistent error handling across different network operations.
///
/// The primary function of this protocol is to convert various types of errors encountered during network requests into a unified
/// `NetworkError` type, which can then be used to handle errors in a consistent manner.
///
/// ## Usage
/// To conform to this protocol, a type must implement the `handle(_:data:response:)` method. This method is responsible for taking
/// an error, along with optional data and response, and returning a `NetworkError` that represents the handled error.
///
/// ```swift
/// class MyErrorHandler: ErrorHandlerProtocol {
///     func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError {
///         // Custom error handling logic
///     }
/// }
/// ```
///
/// ## Methods
public protocol ErrorHandlerProtocol {
    
    /// Handles an error and its associated URL response, returning a `NetworkError`.
    ///
    /// This method takes an error, along with optional data and response, and returns a `NetworkError` that represents the handled error.
    ///
    /// - Parameters:
    ///   - error: The error to handle.
    ///   - data: The data associated with the error, if any.
    ///   - response: The URL response associated with the error.
    /// - Returns: A `NetworkError` representing the handled error.
    func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError
}
