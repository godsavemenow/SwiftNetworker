//
//  SwiftNetworker.swift
//  
//
//  Created by Lucas Silva
//

import Foundation

public class Networker {
    
    let errorHandler: ErrorHandler
    let logger: Logger
    
    public init(errorHandler: ErrorHandler = ErrorHandler(),
         logger: Logger = Logger()
    ) {
        self.errorHandler = errorHandler
        self.logger = logger
    }
    
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T?, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
        let urlRequest = setURLRequest(request)
        
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self]
            data, response, error in
            guard let self else { return }
            
            if let error = error {
                logger.logError(error)
                completion(.failure(errorHandler.handle(error, response: response)))
                return
            }
            
            guard let data = data, let response = response else {
                let customError: NetworkError = .noData
                logger.logError(customError)
                completion(.failure(customError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !HTTPStatusCode.isSuccessful(httpResponse.statusCode) {
                let error = errorHandler.handle(nil, response: response)
                logger.logError(error)
                completion(.failure(error))
                return
            }
            
            let networkResponse = NetworkResponse(data: data, response: response)
            let responses = handleResponse(networkResponse: networkResponse, responseModel: responseModel.self)
            completion(responses)
        }
        
        task.resume()
    }

    
    @available(iOS 15.0, macOS 12.0, *)
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T?) async -> Result<Response<T>, NetworkError> {
        let urlRequest = setURLRequest(request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, HTTPStatusCode.isSuccessful(httpResponse.statusCode) else {
                let customError = errorHandler.handle(nil, response: response)
                logger.logError(customError)
                return .failure(customError)
            }
            
            let networkResponse = NetworkResponse(data: data, response: response)
            let responses = handleResponse(networkResponse: networkResponse, responseModel: responseModel.self)
            return responses
        } catch let error {
            let customError = errorHandler.handle(error, response: nil)
            logger.logError(customError)
            return .failure(customError)
        }
    }
    
    private func handleResponse<T: Decodable>(networkResponse: NetworkResponse, responseModel: T?) -> Result<Response<T>, NetworkError> {
        
        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: networkResponse.data)
            let response = Response(networkResponse: networkResponse, decodedResponse: decodedObject)
            logger.logResponse(response)
            return .success(response)
        } catch let error {
            let customError = errorHandler.handle(error, response: nil)
            return .failure(customError)
        }
    }
        
    private func setURLRequest(_ request: NetworkRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        
        return urlRequest
    }
}
