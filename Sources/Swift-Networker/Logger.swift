//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

class Logger {
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
    
    func logResponse<T: Decodable>(_ response: Response<T>) {
        print("\n--- Response ---")
        print("URL: \(response.networkResponse.response.url?.absoluteString ?? "Unknown URL")")
        if let httpResponse = response.networkResponse.response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
        }
        if let responseString = String(data: response.networkResponse.data, encoding: .utf8) {
            print("Body: \(responseString)")
        }
        
        if let decodedResponse = response.decodedResponse {
            print("\n--- Decoded Response ---")
            print(decodedResponse)
        }
        print("----------------\n")
    }
    
    func logError(_ error: Error) {
        print("\n--- Error ---")
        print("Description: \(error.localizedDescription)")
        print("-------------\n")
    }
}
