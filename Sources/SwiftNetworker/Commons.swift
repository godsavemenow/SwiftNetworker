import Foundation

/// A utility class providing common functionality for handling network responses, errors, and creating URL requests.
///
/// ## Overview
/// The `Commons` class provides a collection of static methods to assist with common tasks related to network operations.
/// This includes handling responses from network requests, managing errors, decoding responses into model types, and creating
/// URL requests from custom network request objects. By centralizing these functionalities, `Commons` ensures consistency and
/// reusability across different network operations.
///
/// The class works closely with the `LoggerProtocol` and `ErrorHandlerProtocol` to log network activities and handle errors
/// in a standardized way. It also simplifies the process of decoding JSON responses and handling various network-related tasks.
///
/// ## Usage
/// The methods in `Commons` are static, meaning they can be called without creating an instance of the class. These methods are
/// typically used within other classes that manage network requests and responses.
///
/// ```swift
/// let urlRequest = Commons.makeURLRequest(from: networkRequest)
/// let result = Commons.handleResponse(data: responseData, response: urlResponse, logger: logger, errorHandler: errorHandler)
/// ```
///
class Commons {
    /// Handles the response for a network request asynchronously.
    /// - Parameters:
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    /// - Returns: A result containing either the network response or a network error.
    static func handleResponse(data: Data?, response: URLResponse?, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol) -> Result<NetworkResponse, NetworkError> {
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
    static func handleDownloadResponse(url: URL?, response: URLResponse?, error: Error?, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol, completion: @escaping (Result<URL, NetworkError>) -> Void) {
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
    static func handleDownloadResponse(url: URL?, response: URLResponse?, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol) -> Result<URL, NetworkError> {
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
    static func decodeResponse<T: Decodable>(_ networkResponse: NetworkResponse, to responseModel: T.Type, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol) -> Result<Response<T>, NetworkError> {
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
    static func makeURLRequest(from request: NetworkRequest) -> URLRequest? {
        guard let url = request.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.bodyData
        return urlRequest
    }
    
    /// Handles request errors.
    /// - Parameters:
    ///   - error: The error received from the network request.
    ///   - data: The data received from the network request.
    ///   - response: The URL response received from the network request.
    ///   - errorCase: The network error case.
    ///   - completion: A closure that handles the result of the network request.
    static func handleRequestError(_ error: Error?, data: Data?, response: URLResponse?, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        let customError = errorHandler.handle(error, data: data, response: response)
        logger.logError(customError)
        completion(.failure(customError))
    }
    
    /// Handles errors for asynchronous requests.
    /// - Parameter error: The error received from the network request.
    /// - Returns: A result containing a network error.
    static func handleError(_ error: Error, logger: LoggerProtocol, errorHandler: ErrorHandlerProtocol) -> NetworkError {
        let customError = errorHandler.handle(error, data: nil, response: nil)
        logger.logError(customError)
        return customError
    }
}
