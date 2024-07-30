import Foundation

/// A class responsible for making network requests and handling responses.
///
/// ## Overview
/// The `Networker` class provides a comprehensive solution for performing network operations such as simple requests, requests with decodable responses,
/// uploads, and downloads. It conforms to the `NetworkerProtocol` and includes methods for managing network tasks, handling responses, logging activities,
/// and caching responses. The class ensures that new requests can be locked and unlocked, providing a mechanism to control network traffic.
///
/// The `Networker` uses `URLSession` to manage network requests and relies on the `ErrorHandlerProtocol` for error handling and `Logger` for logging requests
/// and responses. This design allows for consistent and reusable network operations across different parts of an application. The caching functionality is
/// provided by a component that conforms to the `NetworkCacheProtocol`.
///
/// ## Usage
/// To use the `Networker`, either utilize the shared singleton instance or create a new instance. Configure it with custom error handler, logger, request interceptors,
/// and cache if needed. Call the appropriate methods to perform network requests, upload data, or download files.
///
/// ```swift
/// let networker = Networker.shared
/// let request = NetworkRequest(url: URL(string: "https://example.com")!)
/// networker.perform(request) { result in
///     // Handle result
/// }
/// ```
public class Networker: NetworkerProtocol {
    
    private let errorHandler: ErrorHandlerProtocol
    private let logger: LoggerProtocol
    private var tasks: [UUID: URLSessionTask] = [:]
    private let queue = DispatchQueue(label: "com.networker.taskQueue")
    private let requestInterceptors: [RequestInterceptorProtocol]
    private let allowsCache: Bool
    private let cache: NetworkCacheProtocol?
    private let maxRetries: Int
    private let delayBetweenRetries: TimeInterval
    private let allowRetry: Bool
    private let urlSession: URLSession
    
    /// Singleton instance
    public static let shared = Networker()
    
    /// Initializes the Networker with optional error handler and logger.
    /// - Parameters:
    ///   - errorHandler: An instance of ErrorHandler for handling errors.
    ///   - logger: An instance of Logger for logging requests and responses.
    ///   - requestInterceptors: An array of `RequestInterceptorProtocol` for modifying requests.
    ///   - allowsCache: A boolean indicating whether caching is enabled.
    ///   - cache: An instance of `NetworkCacheProtocol` for caching responses.
    ///   - maxRetries: Maximum number of retry attempts.
    ///   - delayBetweenRetries: Delay between retry attempts.
    ///   - allowRetry: Boolean indicating if retries are allowed.
    public init(errorHandler: ErrorHandlerProtocol = ErrorHandler(),
                logger: LoggerProtocol = Logger(),
                requestInterceptors: [RequestInterceptorProtocol] = [],
                allowsCache: Bool = true,
                cache: NetworkCacheProtocol? = NetworkCache(),
                maxRetries: Int = 3,
                delayBetweenRetries: TimeInterval = 2.0,
                allowRetry: Bool = true,
                urlSession: URLSession = URLSession(configuration: .default)) {
        self.errorHandler = errorHandler
        self.logger = logger
        self.requestInterceptors = requestInterceptors
        self.allowsCache = allowsCache
        self.cache = cache
        self.maxRetries = maxRetries
        self.delayBetweenRetries = delayBetweenRetries
        self.allowRetry = allowRetry
        self.urlSession = urlSession
    }
    
    // MARK: - Task Management
    
    /// Cancels a task with a given UUID.
    /// - Parameter taskId: The UUID of the task to be cancelled.
    public func cancelTask(withId taskId: UUID) {
        queue.sync {
            tasks[taskId]?.cancel()
            tasks.removeValue(forKey: taskId)
        }
    }
    
    /// Cancels all tasks.
    public func cancelAllTasks() {
        queue.sync {
            for (_, task) in tasks {
                task.cancel()
            }
            tasks.removeAll()
        }
    }
    
    // MARK: - Simple Requests
    
    /// Performs a simple network request with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - retries: The current retry attempt count.
    ///   - completion: A closure that handles the result of the request.
    public func perform(_ request: NetworkRequest, retries: Int = 0, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        
        if allowsCache, let urlString = request.url?.absoluteString, let cachedResponse = cache?.getCachedResponse(for: urlString) {
            completion(.success(cachedResponse))
            logger.logResponse("Success", message: "Cached Response")
            logger.logResponse(cachedResponse)
            return
        }
        
        let startTime = Date()
        let taskId = UUID()
        let task = execute(request: request) { [weak self] result in
            guard let self = self else { return }
            self.queue.sync {
                _ = self.tasks.removeValue(forKey: taskId)
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            logger.logResponse("Time Report", message: "Request completed in \(duration) seconds.")

            switch result {
            case .success(let response):
                if self.allowsCache, let urlString = request.url?.absoluteString {
                    self.cache?.cacheResponse(response, for: urlString)
                }
                completion(.success(response))
                
            case .failure(let error):
                if self.allowRetry, retries < self.maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + self.delayBetweenRetries) {
                        self.perform(request, retries: retries + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
        
        guard let task = task else {
            return
        }
        
        queue.sync {
            tasks[taskId] = task
        }
        task.resume()
    }
    
    // MARK: - Decodable Responses
    
    /// Performs a network request and decodes the response into a specified model type with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    ///   - retries: The current retry attempt count.
    ///   - completion: A closure that handles the result of the request.
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, retries: Int = 0, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
        perform(request, retries: retries) { result in
            switch result {
            case .success(let response):
                completion(self.decodeResponse(response, to: responseModel))
            case .failure(let error):
                if self.allowRetry, retries < self.maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + self.delayBetweenRetries) {
                        self.perform(request, responseModel: responseModel, retries: retries + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Upload Requests
    
    /// Performs an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - retries: The current retry attempt count.
    ///   - completion: A closure that handles the result of the request.
    public func performUpload(_ request: NetworkRequest, data: Data, retries: Int = 0, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        
        let startTime = Date()
        let taskId = UUID()
        let task = executeUpload(request: request, data: data) { [weak self] result in
            guard let self = self else { return }
            self.queue.sync {
                _ = self.tasks.removeValue(forKey: taskId)
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            logger.logResponse("Time Report", message: "Upload completed in \(duration) seconds.")

            switch result {
            case .success(let response):
                completion(.success(response))
                
            case .failure(let error):
                if self.allowRetry, retries < self.maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + self.delayBetweenRetries) {
                        self.performUpload(request, data: data, retries: retries + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
        
        guard let task = task else {
            return
        }
        
        queue.sync {
            tasks[taskId] = task
        }
        task.resume()
    }
    
    // MARK: - Download Requests
    
    /// Performs a download request with a completion handler.
    /// - Parameters:
    ///   - request: The download request to be made.
    ///   - retries: The current retry attempt count.
    ///   - completion: A closure that handles the result of the request.
    public func performDownload(_ request: NetworkRequest, retries: Int = 0, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        
        if allowsCache, let urlString = request.url?.absoluteString, let cachedResponse = cache?.getCachedResponse(for: urlString)?.URLResponse.url {
            completion(.success(cachedResponse))
            logger.logResponse("Success", message: "Cached Response")
            return
        }
        
        let startTime = Date()
        let taskId = UUID()
        let task = executeDownload(request: request) { [weak self] result in
            guard let self = self else { return }
            self.queue.sync {
                _ = self.tasks.removeValue(forKey: taskId)
            }
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            logger.logResponse("Time Report", message: "Download completed in \(duration) seconds.")

            switch result {
            case .success(let url):
                if self.allowsCache, let urlString = request.url?.absoluteString {
                    let networkResponse = NetworkResponse(data: Data(), URLResponse: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
                    self.cache?.cacheResponse(networkResponse, for: urlString)
                }
                completion(.success(url))
                
            case .failure(let error):
                if self.allowRetry, retries < self.maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + self.delayBetweenRetries) {
                        self.performDownload(request, retries: retries + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
        
        guard let task = task else {
            return
        }
        
        queue.sync {
            tasks[taskId] = task
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// Executes a network request with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - completion: A closure that handles the result of the request.
    /// - Returns: The URLSessionDataTask associated with the request.
    private func execute(request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> URLSessionDataTask? {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            
            completion(.failure(error))
            return nil
        }
        logger.logRequest(urlRequest)
        intercept(&urlRequest)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        return task
    }
    
    /// Applies all interceptors to the given URLRequest.
    /// - Parameter request: The URLRequest to be modified.
    private func intercept(_ request: inout URLRequest) {
        requestInterceptors.forEach { $0.intercept(&request) }
    }
    
    /// Executes an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be executed.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the request.
    /// - Returns: The URLSessionUploadTask associated with the request.
    private func executeUpload(request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> URLSessionUploadTask? {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            completion(.failure(error))
            return nil
        }
        logger.logRequest(urlRequest)
        intercept(&urlRequest)
        
        let task = urlSession.uploadTask(with: urlRequest, from: data) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        return task
    }
    
    /// Executes a download request with a completion handler.
    /// - Parameters:
    ///   - request: The download request to be executed.
    ///   - completion: A closure that handles the result of the request.
    /// - Returns: The URLSessionDownloadTask associated with the request.
    private func executeDownload(request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) -> URLSessionDownloadTask? {
        guard var urlRequest = Commons.makeURLRequest(from: request) else {
            let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
            logger.logError(error)
            completion(.failure(error))
            return nil
        }
        logger.logRequest(urlRequest)
        
        intercept(&urlRequest)
        let task = urlSession.downloadTask(with: urlRequest) { [weak self] url, response, error in
            guard let self = self else { return }
            self.handleDownloadResponse(url: url, response: response, error: error, completion: completion)
        }
        
        return task
    }
    
    /// Handles the response for a network request with a completion handler.
    /// - Parameters:
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    ///   - error: The error received from the network request.
    ///   - completion: A closure that handles the result of the network request.
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        if let error = error {
            Commons.handleRequestError(error, data: data, response: response, logger: logger, errorHandler: errorHandler, completion: completion)
            return
        }
        
        guard let data = data, let response = response else {
            completion(.failure(NetworkError(errorCase: .noData, apiErrorMessage: nil)))
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, !HTTPStatusCode.isSuccessful(httpResponse.statusCode) {
            Commons.handleRequestError(nil, data: data, response: response, logger: logger, errorHandler: errorHandler, completion: completion)
            return
        }
        
        let networkResponse = NetworkResponse(data: data, URLResponse: response)
        logger.logResponse(networkResponse)
        completion(.success(networkResponse))
    }
    
    /// Handles the response for a download request with a completion handler.
    /// - Parameters:
    ///   - url: The URL of the downloaded file.
    ///   - response: The URL response received from the download request.
    ///   - error: The error received from the download request.
    ///   - completion: A closure that handles the result of the download request.
    private func handleDownloadResponse(url: URL?, response: URLResponse?, error: Error?, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        if let error = error {
            let customError = errorHandler.handle(error, data: nil, response: response)
            logger.logError(customError)
            completion(.failure(customError))
            return
        }
        
        guard let url = url else {
            let customError = NetworkError(errorCase: .noData, apiErrorMessage: nil)
            logger.logError(customError)
            completion(.failure(customError))
            return
        }
        
        logger.logResponse("Success", message: "Download Finished")
        completion(.success(url))
    }
    
    /// Decodes the response data into a specified model type.
    /// - Parameters:
    ///   - networkResponse: The network response containing the data to be decoded.
    ///   - responseModel: The type to decode the response into.
    /// - Returns: A result containing either the decoded response or a network error.
    private func decodeResponse<T: Decodable>(_ networkResponse: NetworkResponse, to responseModel: T.Type) -> Result<Response<T>, NetworkError> {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: networkResponse.data)
            let response = Response(networkResponse: networkResponse, decodedResponse: decodedObject)
            return .success(response)
        } catch let error {
            let customError = errorHandler.handle(error, data: nil, response: nil)
            logger.logError(customError)
            return .failure(customError)
        }
    }
}
