import Foundation

/// A class responsible for caching network responses.
///
/// ## Overview
/// The `NetworkCache` class provides an in-memory cache for network responses. It conforms to the `NetworkCacheProtocol` protocol, allowing it to be used interchangeably with other cache implementations.
/// The class uses `NSCache` to store responses, ensuring that frequently accessed data is readily available without repeated network calls.
/// It also supports cache size limitations and response expiration policies.
///
/// ## Usage
/// Create an instance of `NetworkCache` and use its methods to cache and retrieve network responses.
/// This class is typically used within network handling classes to provide caching functionality.
///
/// Example:
/// ```swift
/// let cache = NetworkCache()
/// let response = NetworkResponse(data: someData, URLResponse: someResponse)
/// cache.cacheResponse(response, for: "https://example.com")
/// let cachedResponse = cache.getCachedResponse(for: "https://example.com")
/// ```
public class NetworkCache: NetworkCacheProtocol {
    public let cache: NSCache<NSString, CachedNetworkResponse>
    private let expirationInterval: TimeInterval
    
    /// Initializes a new instance of `NetworkCache` with an optional cache object and expiration interval.
    ///
    /// - Parameters:
    ///   - cache: An optional `NSCache` object to use for caching network responses.
    ///   - expirationInterval: The time interval after which cached responses should expire.
    public init(cache: NSCache<NSString, CachedNetworkResponse> = NSCache<NSString, CachedNetworkResponse>(), expirationInterval: TimeInterval = 3600) {
        self.cache = cache
        self.expirationInterval = expirationInterval
        self.cache.countLimit = 100 // Set a limit for the number of cached items
    }

    /// Retrieves a cached response for a given network request URL string.
    /// - Parameter urlString: The URL string of the network request.
    /// - Returns: A cached network response if available and not expired, or nil.
    public func getCachedResponse(for urlString: String) -> NetworkResponse? {
        guard let cachedResponse = cache.object(forKey: urlString as NSString) else {
            return nil
        }
        if Date() > cachedResponse.timestamp.addingTimeInterval(expirationInterval) {
            cache.removeObject(forKey: urlString as NSString)
            return nil
        }
        return cachedResponse.response
    }

    /// Caches a network response for a given network request URL string.
    /// - Parameters:
    ///   - response: The network response to cache.
    ///   - urlString: The URL string of the network request associated with the response.
    public func cacheResponse(_ response: NetworkResponse, for urlString: String) {
        let cachedResponse = CachedNetworkResponse(response: response, timestamp: Date())
        cache.setObject(cachedResponse, forKey: urlString as NSString)
    }
}

/// A wrapper class to store network response along with the timestamp of when it was cached.
public class CachedNetworkResponse {
    let response: NetworkResponse
    let timestamp: Date
    
    init(response: NetworkResponse, timestamp: Date) {
        self.response = response
        self.timestamp = timestamp
    }
}
