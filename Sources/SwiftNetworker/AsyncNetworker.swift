import Foundation

/// A class responsible for making network requests and handling responses.
///
/// ## Overview
/// The `AsyncNetworker` class provides a standardized implementation for performing asynchronous network requests using Swift's `async/await` syntax.
/// This class conforms to the `AsyncNetworkerProtocol` and includes methods for performing basic network requests, requests with decodable responses,
/// upload requests, and download requests.
///
/// The class is designed to simplify the process of making network requests by handling common tasks such as logging, error handling, response decoding,
/// and caching. It uses `URLSession` for network communication and leverages the `ErrorHandlerProtocol` and `Logger` for error handling and logging,
/// respectively. The caching functionality is provided by a component that conforms to the `NetworkCacheProtocol`.
///
/// ## Usage
/// To use the `AsyncNetworker`, create an instance of the class and call the appropriate method for the network operation you want to perform. You can
/// optionally provide your own implementations of `ErrorHandlerProtocol`, `Logger`, and `NetworkCacheProtocol` for custom error handling, logging,
/// and caching behavior.
///
/// ```swift
/// @available(iOS 15.0, macOS 12.0, *)
/// let networker = AsyncNetworker()
/// let request = NetworkRequest(urlString: "https://example.com")
/// let result = await networker.performAsync(request)
/// ```
///
/// A class responsible for making network requests and handling responses.
@available(iOS 15.0, macOS 12.0, *)
public class AsyncNetworker: AsyncNetworkerProtocol {
    
    private let errorHandler: ErrorHandlerProtocol
    private let logger: LoggerProtocol
    private let requestInterceptors: [RequestInterceptorProtocol]
    private let allowsCache: Bool
    private let cache: NetworkCacheProtocol?
    private let maxRetries: Int
    private let delayBetweenRetries: TimeInterval
    private let allowRetry: Bool

    /// Initializes the AsyncNetworker with optional error handler, logger, request interceptors, and cache option.
    /// - Parameters:
    ///   - errorHandler: An instance of `ErrorHandlerProtocol` for handling errors.
    ///   - logger: An instance of `LoggerProtocol` for logging requests and responses.
    ///   - requestInterceptors: An array of `RequestInterceptorProtocol` for modifying requests.
    ///   - allowsCache: A boolean indicating whether caching is enabled.
    ///   - cache: An instance of `NetworkCacheProtocol` for caching responses.
    ///   - maxRetries: Maximum number of retry attempts.
    ///   - delayBetweenRetries: Delay between retry attempts.
    ///   - allowRetry: Boolean indicating if retries are allowed.
    public init(
        errorHandler: ErrorHandlerProtocol = ErrorHandler(),
        logger: LoggerProtocol = Logger(),
        requestInterceptors: [RequestInterceptorProtocol] = [],
        allowsCache: Bool = true,
        cache: NetworkCacheProtocol? = NetworkCache(),
        maxRetries: Int = 3,
        delayBetweenRetries: TimeInterval = 2.0,
        allowRetry: Bool = true
    ) {
        self.errorHandler = errorHandler
        self.logger = logger
        self.requestInterceptors = requestInterceptors
        self.allowsCache = allowsCache
        self.cache = cache
        self.maxRetries = maxRetries
        self.delayBetweenRetries = delayBetweenRetries
        self.allowRetry = allowRetry
    }
    
    // MARK: - Simple Requests
    
    /// Performs a simple network request asynchronously.
    /// - Parameter request: The network request to be made.
    /// - Parameter retries: The current retry attempt count.
    /// - Returns: A result containing either the network response or a network error.
    public func performAsync(_ request: NetworkRequest, retries: Int = 0) async -> Result<NetworkResponse, NetworkError> {
        if allowsCache, let urlString = request.url?.absoluteString, let cachedResponse = cache?.getCachedResponse(for: urlString) {
            logger.logResponse("Success", message: "Cached Response")
            logger.logResponse(cachedResponse)
            return .success(cachedResponse)
        }
        
        let result = await executeAsync(request: request)
        if allowsCache, case .success(let response) = result, let urlString = request.url?.absoluteString {
            cache?.cacheResponse(response, for: urlString)
        }
        
        if allowRetry, case .failure = result, retries < maxRetries {
            try? await Task.sleep(nanoseconds: UInt64(delayBetweenRetries * 1_000_000_000))
            return await performAsync(request, retries: retries + 1)
        }
        
        return result
    }
    
    /// Applies all interceptors to the given URLRequest.
    /// - Parameter request: The URLRequest to be modified.
    private func intercept(_ request: inout URLRequest) {
        requestInterceptors.forEach { $0.intercept(&request) }
    }
    
    // MARK: - Decodable Responses
    
    /// Performs a network request and decodes the response into a specified model type asynchronously.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the decoded response or a network error.
    public func performAsync<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, retries: Int = 0) async -> Result<Response<T>, NetworkError> {
        let result = await performAsync(request, retries: retries)
        switch result {
        case .success(let response):
            return Commons.decodeResponse(response, to: responseModel, logger: logger, errorHandler: errorHandler)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Upload Requests
    
    /// Performs an upload request asynchronously.
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the network response or a network error.
    public func performUploadAsync(_ request: NetworkRequest, data: Data, retries: Int = 0) async -> Result<NetworkResponse, NetworkError> {
        let result = await executeUploadAsync(request: request, data: data)
        
        if allowRetry, case .failure = result, retries < maxRetries {
            try? await Task.sleep(nanoseconds: UInt64(delayBetweenRetries * 1_000_000_000))
            return await performUploadAsync(request, data: data, retries: retries + 1)
        }
        
        return result
    }
    
    // MARK: - Download Requests
    
    /// Performs a download request asynchronously.
    /// - Parameters:
    ///   - request: The download request to be made.
    ///   - retries: The current retry attempt count.
    /// - Returns: A result containing either the file URL or a network error.
    public func performDownloadAsync(_ request: NetworkRequest, retries: Int = 0) async -> Result<URL, NetworkError> {
        if allowsCache, let urlString = request.url?.absoluteString, let cachedResponse = cache?.getCachedResponse(for: urlString) {
            logger.logResponse("Success", message: "Cached Response")
            return .success(cachedResponse.URLResponse.url!)
        }

        let result = await executeDownloadAsync(request: request)
        if allowsCache, case .success(let url) = result, let urlString = request.url?.absoluteString {
            let networkResponse = NetworkResponse(data: Data(), URLResponse: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
            cache?.cacheResponse(networkResponse, for: urlString)
        }
        
        if allowRetry, case .failure = result, retries < maxRetries {
            try? await Task.sleep(nanoseconds: UInt64(delayBetweenRetries * 1_000_000_000))
            return await performDownloadAsync(request, retries: retries + 1)
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    /// Executes a network request asynchronously.
    /// - Parameters:
    ///   - request: The network request to be executed.
    /// - Returns: A result containing either the network response or a network error.
    private func executeAsync(request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            return .failure(error)
        }
        
        // Intercept the request to add authentication or other headers
        intercept(&urlRequest)
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            return Commons.handleResponse(data: data, response: response, logger: logger, errorHandler: errorHandler)
        } catch let error {
            return .failure(Commons.handleError(error, logger: logger, errorHandler: errorHandler))
        }
    }
    
    /// Executes an upload request asynchronously.
    /// - Parameters:
    ///   - request: The upload request to be executed.
    ///   - data: The data to be uploaded.
    /// - Returns: A result containing either the network response or a network error.
    private func executeUploadAsync(request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError> {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            return .failure(error)
        }
        
        // Intercept the request to add authentication or other headers
        intercept(&urlRequest)
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: data)
            return Commons.handleResponse(data: data, response: response, logger: logger, errorHandler: errorHandler)
        } catch let error {
            return .failure(Commons.handleError(error, logger: logger, errorHandler: errorHandler))
        }
    }
    
    /// Executes a download request asynchronously.
    /// - Parameters:
    ///   - request: The download request to be executed.
    /// - Returns: A result containing either the file URL or a network error.
    private func executeDownloadAsync(request: NetworkRequest) async -> Result<URL, NetworkError> {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            return .failure(error)
        }
        
        // Intercept the request to add authentication or other headers
        intercept(&urlRequest)
        logger.logRequest(urlRequest)
        
        do {
            let (url, response) = try await URLSession.shared.download(for: urlRequest)
            return Commons.handleDownloadResponse(url: url, response: response, logger: logger, errorHandler: errorHandler)
        } catch let error {
            return .failure(Commons.handleError(error, logger: logger, errorHandler: errorHandler))
        }
    }
}
