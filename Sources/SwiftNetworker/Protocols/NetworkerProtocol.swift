import Foundation

/// A protocol defining the methods for a networker.
///
/// ## Overview
/// The `NetworkerProtocol` provides a standardized interface for performing various types of network requests,
/// including basic requests, requests with decodable responses, upload requests, and download requests. Conforming
/// to this protocol ensures consistent handling of network operations across different implementations.
///
/// This protocol is designed to support asynchronous network operations using completion handlers. Each method in this
/// protocol takes a completion handler that is called with the result of the network operation, which can be either a
/// successful response or a network error.
///
/// ## Usage
/// To conform to this protocol, a type must implement all the methods defined herein. This typically involves sending
/// network requests using URLSession, handling the responses, and invoking the completion handlers with the appropriate
/// results.
///
/// ```swift
/// class MyNetworker: NetworkerProtocol {
///     func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
///         // Implementation of the perform method
///     }
///     func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
///         // Implementation of the perform method with decodable response
///     }
///     func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
///         // Implementation of the performUpload method
///     }
///     func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) {
///         // Implementation of the performDownload method
///     }
/// }
/// ```
///
/// ## Methods
public protocol NetworkerProtocol {
    
    /// Performs a simple network request with a completion handler.
    ///
    /// This method sends a network request and invokes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - completion: A closure that handles the result of the request, containing either a `NetworkResponse` or a `NetworkError`.
    func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    
    /// Performs a network request and decodes the response into a specified model type with a completion handler.
    ///
    /// This method sends a network request, receives the response, decodes it into a specified model type, and invokes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    ///   - completion: A closure that handles the result of the request, containing either a decoded response or a `NetworkError`.
    func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void)
    
    /// Performs an upload request with a completion handler.
    ///
    /// This method uploads data to a server as part of the specified network request and invokes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the upload, containing either a `NetworkResponse` or a `NetworkError`.
    func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    
    /// Performs a download request with a completion handler.
    ///
    /// This method sends a network request to download content from a server and invokes the completion handler with the result.
    ///
    /// - Parameters:
    ///   - request: The download request to be made.
    ///   - completion: A closure that handles the result of the download, containing either a file URL or a `NetworkError`.
    func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void)
}
