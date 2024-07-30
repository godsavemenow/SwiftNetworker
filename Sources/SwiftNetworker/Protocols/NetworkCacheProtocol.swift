import Foundation

/// A protocol defining the methods for caching network responses.
///
/// ## Overview
/// The `NetworkCacheProtocol` protocol provides a blueprint for caching network responses. It defines methods for retrieving and caching responses associated with network request URLs.
/// Implementations of this protocol can be used to provide caching functionality within network handling classes, improving performance and efficiency by avoiding repeated network calls.
///
/// ## Usage
/// To conform to the `NetworkCacheProtocol`, a class must implement the following methods:
/// - `getCachedResponse(for:)` to retrieve cached responses.
/// - `cacheResponse(_:for:)` to store responses in the cache.
///
/// Example implementation:
/// ```swift
/// class NetworkCache: NetworkCacheProtocol {
///     private let cache = NSCache<NSString, NetworkResponse>()
///
///     func getCachedResponse(for urlString: String) -> NetworkResponse? {
///         return cache.object(forKey: urlString as NSString)
///     }
///
///     func cacheResponse(_ response: NetworkResponse, for urlString: String) {
///         cache.setObject(response, forKey: urlString as NSString)
///     }
/// }
/// ```
public protocol NetworkCacheProtocol {
    /// Retrieves a cached response for a given network request URL string.
    /// - Parameter urlString: The URL string of the network request.
    /// - Returns: A cached network response if available, or nil.
    func getCachedResponse(for urlString: String) -> NetworkResponse?

    /// Caches a network response for a given network request URL string.
    /// - Parameters:
    ///   - response: The network response to cache.
    ///   - urlString: The URL string of the network request associated with the response.
    func cacheResponse(_ response: NetworkResponse, for urlString: String)
}
