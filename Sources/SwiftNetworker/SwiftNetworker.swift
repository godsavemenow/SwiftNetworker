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
    
    private func execute(callSync request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        let urlRequest = setURLRequest(request)
        
        logger.logRequest(urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self]
            data, response, error in
            guard let self else { return }
            
            if let error = error {
                let customError = errorHandler.handle(error, response: response)
                logger.logError(customError)
                completion(.failure(customError))
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
            
            let networkResponse = NetworkResponse(data: data, URLResponse: response)
            logger.logResponse(networkResponse)

            completion(.success(networkResponse))
        }
        
        task.resume()
    }
    
    public func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        execute(callSync: request) { result in
            completion(result)
        }
    }
    
    public func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void) {
        
        execute(callSync: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                let result = self.handleResponse(
                    networkResponse: response,
                    responseModel: T.self)
                completion(
                    result
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func perform(async request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        return await execute(callAsync: request)
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public func perform<T: Decodable>(async request: NetworkRequest, responseModel: T.Type) async -> (Result<Response<T>, NetworkError>) {
        let result = await execute(callAsync: request)
        
        switch result {
        case .success(let response):
            return self.handleResponse(
                    networkResponse: response,
                    responseModel: T.self
            )
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    private func execute(callAsync request: NetworkRequest) async -> Result<NetworkResponse, NetworkError> {
        let urlRequest = setURLRequest(request)
        logger.logRequest(urlRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, HTTPStatusCode.isSuccessful(httpResponse.statusCode) else {
                let customError = errorHandler.handle(nil, response: response)
                logger.logError(customError)
                return .failure(customError)
            }
            
            let networkResponse = NetworkResponse(data: data, URLResponse: response)
            logger.logResponse(networkResponse)
            return .success(networkResponse)
        } catch let error {
            let customError = errorHandler.handle(error, response: nil)
            logger.logError(customError)
            return .failure(customError)
        }
    }
    
    private func handleResponse<T: Decodable>(networkResponse: NetworkResponse, responseModel: T.Type) -> Result<Response<T>, NetworkError> {

        let decoder = JSONDecoder()
        do {
            let decodedObject = try decoder.decode(T.self, from: networkResponse.data)
            let response = Response(networkResponse: networkResponse, decodedResponse: decodedObject)
            return .success(response)
        } catch let error {
            let customError = errorHandler.handle(error, response: nil)
            logger.logError(customError)
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
