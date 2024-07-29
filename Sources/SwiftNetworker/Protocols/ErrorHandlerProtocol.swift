import Foundation

/// A protocol defining the contract for error handling.
public protocol ErrorHandlerProtocol {
    /// Handles an error and its associated URL response, returning a `NetworkError`.
    ///
    /// - Parameters:
    ///   - error: The error to handle.
    ///   - response: The URL response associated with the error.
    /// - Returns: A `NetworkError` representing the handled error.
    func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError
}
