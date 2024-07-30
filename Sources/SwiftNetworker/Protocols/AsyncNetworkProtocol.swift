import Foundation

/// A protocol that defines the methods for performing asynchronous network requests.
///
/// ## Overview
/// The `AsyncNetworkerProtocol` is designed to provide a standardized interface for executing asynchronous network requests.
/// This protocol includes methods for performing basic network requests, as well as upload and download operations. It is suitable
/// for use in applications targeting iOS 15.0, macOS 12.0, or later.
///
/// Conforming types are expected to handle the intricacies of network communication, including error handling, data encoding, and decoding,
/// while providing a simple and consistent API for clients to use. The protocol leverages Swift's `async/await` to facilitate asynchronous
/// operations, making it easier to write and maintain asynchronous code.
///
/// ## Usage
/// To conform to this protocol, a type must implement all the methods defined herein. Example usage might include making an API call,
/// uploading a file to a server, or downloading content from the internet.
///
/// ```swift
/// @available(iOS 15.0, macOS 12.0, *)
/// class MyNetworker: AsyncNetworkerProtocol {
///     // Implementation of protocol methods
/// }
/// ```
///
/// ## Methods
@available(iOS 15.0, macOS 12.0, *)
public protocol AsyncNetworkerProtocol {
    
    /// Performs a simple network request asynchronously.
    ///
    /// This method sends a network request and returns the result asynchronously.
    ///
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the network response or a network error.
    func performAsync(_ request: NetworkRequest, retries: Int) async -> Result<NetworkResponse, NetworkError>
    
    /// Performs a network request and decodes the response into a specified model type asynchronously.
    ///
    /// This method sends a network request, receives the response, and decodes it into a specified model type asynchronously.
    ///
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the decoded response or a network error.
    func performAsync<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, retries: Int) async -> Result<Response<T>, NetworkError>
    
    /// Performs an upload request asynchronously.
    ///
    /// This method uploads data to a server as part of the specified network request and returns the result asynchronously.
    ///
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the network response or a network error.
    func performUploadAsync(_ request: NetworkRequest, data: Data, retries: Int) async -> Result<NetworkResponse, NetworkError>
    
    /// Performs a download request asynchronously.
    ///
    /// This method sends a network request to download content from a server and returns the result asynchronously.
    ///
    /// - Parameters:
    ///   - request: The download request to be made.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the file URL or a network error.
    func performDownloadAsync(_ request: NetworkRequest, retries: Int) async -> Result<URL, NetworkError>
}
