import Foundation

/// A protocol defining the methods for logging network requests, responses, and errors.
///
/// ## Overview
/// The `LoggerProtocol` provides a standardized interface for logging various aspects of network communication,
/// including requests, responses, and errors. Conforming to this protocol allows for consistent logging across different
/// network operations, facilitating debugging and monitoring.
///
/// The protocol defines methods for logging outgoing network requests, incoming network responses, and errors that occur
/// during network operations. Implementing these methods ensures that all relevant information about network interactions
/// is captured and can be reviewed later.
///
/// ## Usage
/// To conform to this protocol, a type must implement all the methods defined herein. This typically involves writing log
/// entries to a file, console, or remote logging server.
///
/// ```swift
/// class MyLogger: LoggerProtocol {
///     func logRequest(_ request: URLRequest) {
///         // Custom logic to log the request
///     }
///     func logResponse(_ response: NetworkResponse) {
///         // Custom logic to log the response
///     }
///     func logResponse(_ title: String, message: String) {
///         // Custom logic to log the response with a title and message
///     }
///     func logError(_ error: NetworkError) {
///         // Custom logic to log the error
///     }
/// }
/// ```
///
/// ## Methods
public protocol LoggerProtocol {
    
    /// Logs an outgoing network request.
    ///
    /// This method logs the details of an outgoing network request, including the URL, HTTP method, headers, and body.
    ///
    /// - Parameter request: The network request to be logged.
    func logRequest(_ request: URLRequest)
    
    /// Logs an incoming network response.
    ///
    /// This method logs the details of an incoming network response, including the status code, headers, and body.
    ///
    /// - Parameter response: The network response to be logged.
    func logResponse(_ response: NetworkResponse)
    
    /// Logs a response with a custom title and message.
    ///
    /// This method logs a response with a specified title and message. It can be used for logging informational messages
    /// or custom responses.
    ///
    /// - Parameters:
    ///   - title: The title of the log entry.
    ///   - message: The message of the log entry.
    func logResponse(_ title: String, message: String)
    
    /// Logs a network error.
    ///
    /// This method logs the details of a network error, including the error message and any relevant error codes.
    ///
    /// - Parameter error: The network error to be logged.
    func logError(_ error: NetworkError)
}
