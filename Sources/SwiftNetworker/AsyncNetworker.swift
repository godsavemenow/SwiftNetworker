import Foundation

/// A class responsible for making network requests and handling responses.
public class AsyncNetworker {
    
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
    
    /// Performs a simple network request asynchronously.
    /// - Parameter request: The network request to be made.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performAsync(_ request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        await executeAsync(request: request)
    }
    
    // MARK: - Decodable Responses
    
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
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performUploadAsync(_ request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError> {
        await executeUploadAsync(request: request, data: data)
    }
    
    // MARK: - Download Requests
    
    /// Performs a download request asynchronously.
    /// - Parameters:
    ///   - request: The download request to be made.
    /// - Returns: A result containing either the file URL or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    public func performDownloadAsync(_ request: NetworkRequest) async -> Result<URL, NetworkError> {
        await executeDownloadAsync(request: request)
    }
    
    // MARK: - Private Methods
    
    /// Executes a network request asynchronously.
    /// - Parameters:
    ///   - request: The network request to be executed.
    /// - Returns: A result containing either the network response or a network error.
    @available(iOS 15.0, macOS 12.0, *)
    private func executeAsync(request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        let urlRequest = Commons.makeURLRequest(from: request)
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
    @available(iOS 15.0, macOS 12.0, *)
    private func executeUploadAsync(request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError> {
        let urlRequest = Commons.makeURLRequest(from: request)
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
    @available(iOS 15.0, macOS 12.0, *)
    private func executeDownloadAsync(request: NetworkRequest) async -> Result<URL, NetworkError> {
        let urlRequest = Commons.makeURLRequest(from: request)
        logger.logRequest(urlRequest)
        
        do {
            let (url, response) = try await URLSession.shared.download(for: urlRequest)
            return Commons.handleDownloadResponse(url: url, response: response, logger: logger, errorHandler: errorHandler)
        } catch let error {
            return .failure(Commons.handleError(error, logger: logger, errorHandler: errorHandler))
        }
    }
}
