import Foundation

/// A class responsible for making network requests and handling responses.
public class Networker: NetworkerProtocol {
    
    private let errorHandler: ErrorHandlerProtocol
    private let logger: Logger
    private var tasks: [UUID: URLSessionTask] = [:]
    private let queue = DispatchQueue(label: "com.networker.taskQueue")
    private var isLocked = false

    /// Singleton instance
    public static let shared = Networker()
    
    /// Initializes the Networker with optional error handler and logger.
    /// - Parameters:
    ///   - errorHandler: An instance of ErrorHandler for handling errors.
    ///   - logger: An instance of Logger for logging requests and responses.
    public init(errorHandler: ErrorHandlerProtocol = ErrorHandler(), logger: Logger = Logger()) {
        self.errorHandler = errorHandler
        self.logger = logger
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
    
    // MARK: - Lock Management
    
    /// Locks the Networker class to prevent new requests from being made.
    public func lock() {
        queue.sync {
            isLocked = true
        }
    }
    
    /// Unlocks the Networker class to allow new requests to be made.
    public func unlock() {
        queue.sync {
            isLocked = false
        }
    }
    
    // MARK: - Simple Requests
    
    /// Performs a simple network request with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - completion: A closure that handles the result of the request.
    public func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        queue.sync {
            guard !isLocked else {
                completion(.failure(NetworkError(errorCase: .locked, apiErrorMessage: "Networker is locked.")))
                return
            }
        }
        
        let taskId = UUID()
        let task = execute(request: request) { [weak self] result in
            self?.queue.sync {
                _ = self?.tasks.removeValue(forKey: taskId)
            }
            completion(result)
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
    ///   - completion: A closure that handles the result of the request.
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
        perform(request) { result in
            switch result {
            case .success(let response):
                completion(self.decodeResponse(response, to: responseModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Upload Requests
    
    /// Performs an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the request.
    public func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        queue.sync {
            guard !isLocked else {
                completion(.failure(NetworkError(errorCase: .locked, apiErrorMessage: "Networker is locked.")))
                return
            }
        }
        
        let taskId = UUID()
        let task = executeUpload(request: request, data: data) { [weak self] result in
            self?.queue.sync {
                _ = self?.tasks.removeValue(forKey: taskId)
            }
            completion(result)
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
    ///   - completion: A closure that handles the result of the request.
    public func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        queue.sync {
            guard !isLocked else {
                completion(.failure(NetworkError(errorCase: .locked, apiErrorMessage: "Networker is locked.")))
                return
            }
        }
        
        let taskId = UUID()
        let task = executeDownload(request: request) { [weak self] result in
            self?.queue.sync {
                _ = self?.tasks.removeValue(forKey: taskId)
            }
            completion(result)
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
    private func execute(request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> URLSessionDataTask {
        let urlRequest = Commons.makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        return task
    }
    
    /// Executes an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be executed.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the request.
    /// - Returns: The URLSessionUploadTask associated with the request.
    private func executeUpload(request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> URLSessionUploadTask {
        let urlRequest = Commons.makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        return task
    }
    
    /// Executes a download request with a completion handler.
    /// - Parameters:
    ///   - request: The download request to be executed.
    ///   - completion: A closure that handles the result of the request.
    /// - Returns: The URLSessionDownloadTask associated with the request.
    private func executeDownload(request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) -> URLSessionDownloadTask {
        let urlRequest = Commons.makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.downloadTask(with: urlRequest) { [weak self] url, response, error in
            self?.handleDownloadResponse(url: url, response: response, error: error, completion: completion)
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
