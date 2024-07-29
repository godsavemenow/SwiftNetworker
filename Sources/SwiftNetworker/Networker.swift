import Foundation

/// A class responsible for making network requests and handling responses.
public class Networker: NetworkerProtocol {
    
    private let errorHandler: ErrorHandlerProtocol
    private let logger: Logger
    
    /// Initializes the Networker with optional error handler and logger.
    /// - Parameters:
    ///   - errorHandler: An instance of ErrorHandler for handling errors.
    ///   - logger: An instance of Logger for logging requests and responses.
    public init(errorHandler: ErrorHandlerProtocol = ErrorHandler(), logger: Logger = Logger()) {
        self.errorHandler = errorHandler
        self.logger = logger
    }
    
    // MARK: - Simple Requests
    
    /// Performs a simple network request with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - completion: A closure that handles the result of the request.
    public func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        execute(request: request, completion: completion)
    }
    
    /// Performs a simple network request asynchronously.
    /// - Parameter request: The network request to be made.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performAsync(_ request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        await executeAsync(request: request)
    }
    
    // MARK: - Decodable Responses
    
    /// Performs a network request and decodes the response into a specified model type with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    ///   - completion: A closure that handles the result of the request.
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
        execute(request: request) { result in
            switch result {
            case .success(let response):
                completion(self.decodeResponse(response, to: responseModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Performs a network request and decodes the response into a specified model type asynchronously.
    /// - Parameters:
    ///   - request: The network request to be made.
    ///   - responseModel: The type to decode the response into.
    /// - Returns: A result containing either the decoded response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performAsync<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type) async -> Result<Response<T>, NetworkError> {
        let result = await executeAsync(request: request)
        switch result {
        case .success(let response):
            return decodeResponse(response, to: responseModel)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Upload Requests
    
    /// Performs an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the request.
    public func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        executeUpload(request: request, data: data, completion: completion)
    }
    
    /// Performs an upload request asynchronously.
    /// - Parameters:
    ///   - request: The upload request to be made.
    ///   - data: The data to be uploaded.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performUploadAsync(_ request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError> {
        await executeUploadAsync(request: request, data: data)
    }
    
    // MARK: - Download Requests
    
    /// Performs a download request with a completion handler.
    /// - Parameters:
    ///   - request: The download request to be made.
    ///   - completion: A closure that handles the result of the request.
    public func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        executeDownload(request: request, completion: completion)
    }
    
    /// Performs a download request asynchronously.
    /// - Parameters:
    ///   - request: The download request to be made.
    /// - Returns: A result containing either the file URL or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performDownloadAsync(_ request: NetworkRequest) async -> Result<URL, NetworkError> {
        await executeDownloadAsync(request: request)
    }
    
    // MARK: - Private Methods
    
    /// Executes a network request with a completion handler.
    /// - Parameters:
    ///   - request: The network request to be executed.
    ///   - completion: A closure that handles the result of the request.
    private func execute(request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    /// Executes a network request asynchronously.
    /// - Parameters:
    ///   - request: The network request to be executed.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func executeAsync(request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            return handleResponse(data: data, response: response)
        } catch let error {
            return .failure(handleError(error))
        }
    }
    
    /// Executes an upload request with a completion handler.
    /// - Parameters:
    ///   - request: The upload request to be executed.
    ///   - data: The data to be uploaded.
    ///   - completion: A closure that handles the result of the request.
    private func executeUpload(request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    /// Executes an upload request asynchronously.
    /// - Parameters:
    ///   - request: The upload request to be executed.
    ///   - data: The data to be uploaded.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func executeUploadAsync(request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError> {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: data)
            return handleResponse(data: data, response: response)
        } catch let error {
            return .failure(handleError(error))
        }
    }
    
    /// Executes a download request with a completion handler.
    /// - Parameters:
    ///   - request: The download request to be executed.
    ///   - completion: A closure that handles the result of the request.
    private func executeDownload(request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.downloadTask(with: urlRequest) { [weak self] url, response, error in
            self?.handleDownloadResponse(url: url, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    /// Executes a download request asynchronously.
    /// - Parameters:
    ///   - request: The download request to be executed.
    /// - Returns: A result containing either the file URL or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func executeDownloadAsync(request: NetworkRequest) async -> Result<URL, NetworkError> {
        let urlRequest = makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        do {
            let (url, response) = try await URLSession.shared.download(for: urlRequest)
            return handleDownloadResponse(url: url, response: response)
        } catch let error {
            return .failure(handleError(error))
        }
    }
    
    /// Handles the response for a network request with a completion handler.
    /// - Parameters:
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    ///   - error: The error received from the network request.
    ///   - completion: A closure that handles the result of the network request.
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        if let error = error {
            handleRequestError(error, data: data, response: response, completion: completion)
            return
        }
        
        guard let data = data, let response = response else {
            completion(.failure(NetworkError(errorCase: .noData, apiErrorMessage: nil)))
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, !HTTPStatusCode.isSuccessful(httpResponse.statusCode) {
            handleRequestError(nil, data: data, response: response, completion: completion)
            return
        }
        
        let networkResponse = NetworkResponse(data: data, URLResponse: response)
        logger.logResponse(networkResponse)
        completion(.success(networkResponse))
    }
    
    /// Handles the response for a network request asynchronously.
    /// - Parameters:
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func handleResponse(data: Data?, response: URLResponse?) -> Result<NetworkResponse, NetworkError> {
        guard let data = data, let response = response else {
            return .failure(NetworkError(errorCase: .noData, apiErrorMessage: nil))
        }
        
        if let httpResponse = response as? HTTPURLResponse, !HTTPStatusCode.isSuccessful(httpResponse.statusCode) {
            return .failure(errorHandler.handle(nil, data: data, response: response))
        }
        
        let networkResponse = NetworkResponse(data: data, URLResponse: response)
        logger.logResponse(networkResponse)
        return .success(networkResponse)
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
    
    /// Handles the response for a download request asynchronously.
    /// - Parameters:
    ///   - url: The URL of the downloaded file.
    ///   - response: The URL response received from the download request.
    /// - Returns: A result containing either the file URL or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func handleDownloadResponse(url: URL?, response: URLResponse?) -> Result<URL, NetworkError> {
        guard let url = url else {
            return .failure(NetworkError(errorCase: .noData, apiErrorMessage: nil))
        }
        
        if let httpResponse = response as? HTTPURLResponse, !HTTPStatusCode.isSuccessful(httpResponse.statusCode) {
            return .failure(errorHandler.handle(nil, data: nil, response: response))
        }
        
        logger.logResponse("Success", message: "Download Finished")
        return .success(url)
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
    
    /// Creates a URL request from a network request.
    /// - Parameter request: The network request to be converted.
    /// - Returns: A URL request created from the network request.
    private func makeURLRequest(from request: NetworkRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        return urlRequest
    }
    
    /// Handles request errors.
    /// - Parameters:
    ///   - error: The error received from the network request.
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    ///   - errorCase: The network error case.
    ///   - completion: A closure that handles the result of the network request.
    private func handleRequestError(_ error: Error?, data: Data?, response: URLResponse?, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        let customError = errorHandler.handle(error, data: data, response: response)
        logger.logError(customError)
        completion(.failure(customError))
    }
    
    /// Handles errors for asynchronous requests.
    /// - Parameter error: The error received from the network request.
    /// - Returns: A result containing a network error.
    private func handleError(_ error: Error) -> NetworkError {
        let customError = errorHandler.handle(error, data: nil, response: nil)
        logger.logError(customError)
        return customError
    }
}
