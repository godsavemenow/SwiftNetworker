import XCTest
@testable import SwiftNetworker

struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}

class ResponseTests: XCTestCase {

    func testResponseInitialization() {
        let data = """
        {
            "id": 1,
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        let url = URL(string: "https://example.com")!
        let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        let decodedResponse = try! JSONDecoder().decode(TestModel.self, from: data)
        
        let response = Response(networkResponse: networkResponse, decodedResponse: decodedResponse)
        
        XCTAssertEqual(response.networkResponse.data, data)
        XCTAssertEqual(response.networkResponse.URLResponse.url, url)
        XCTAssertEqual(response.decodedResponse, decodedResponse)
    }
    
    func testResponseInitializationWithDifferentData() {
        let data = """
        {
            "id": 2,
            "name": "Another Test"
        }
        """.data(using: .utf8)!
        
        let url = URL(string: "https://example.org")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        let decodedResponse = try! JSONDecoder().decode(TestModel.self, from: data)
        
        let response = Response(networkResponse: networkResponse, decodedResponse: decodedResponse)
        
        XCTAssertEqual(response.networkResponse.data, data)
        XCTAssertEqual(response.networkResponse.URLResponse.url, url)
        XCTAssertEqual((response.networkResponse.URLResponse as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual(response.decodedResponse, decodedResponse)
    }
}
