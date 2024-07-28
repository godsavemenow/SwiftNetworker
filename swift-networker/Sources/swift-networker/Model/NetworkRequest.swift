//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public struct NetworkRequest {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let body: Data?
    
    public init(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case unknown(Error)
}

public struct NetworkResponse {
    public let data: Data
    public let response: URLResponse
}

public class Networker {
    public static func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.body
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data, let response = response else {
                completion(.failure(.noData))
                return
            }
            
            let networkResponse = NetworkResponse(data: data, response: response)
            completion(.success(networkResponse))
        }
        
        task.resume()
    }
}
