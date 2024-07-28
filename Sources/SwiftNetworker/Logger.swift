//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public class Logger {
    
    public init() {}

    func logRequest(_ request: URLRequest) {
        print("\n--- Request ---")
        print("Method: \(request.httpMethod ?? "Unknown Method")")
        print("URL: \(request.url?.absoluteString ?? "Unknown URL")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("---------------\n")
    }
    
    func logResponse(_ response: NetworkResponse) {
        print("\n--- Response ---")
        print("URL: \(response.URLResponse.url?.absoluteString ?? "Unknown URL")")
        if let httpResponse = response.URLResponse as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
        }
        if let responseString = String(data: response.data, encoding: .utf8) {
            print("Body: \(responseString)")
        }
        print("----------------\n")
    }
    
    func logError(_ error: NetworkError) {
        print("\n--- Error ---")
        print("Description: \(error.description)")
        print("-------------\n")
    }
}
