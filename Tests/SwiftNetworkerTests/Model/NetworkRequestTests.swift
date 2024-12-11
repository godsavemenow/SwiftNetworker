import XCTest
@testable import SwiftNetworker

struct TestBody: Codable, Equatable {
    let key: String
}

class NetworkRequestTests: XCTestCase {

    func testNetworkRequestInitializationWithURLString() {
        let urlString = "https://example.com/api/resource"
        let headers = ["Content-Type": "application/json"]
        let body = TestBody(key: "value")
        
        let request = NetworkRequest(urlString: urlString, method: .post, headers: headers, body: body)
        
        XCTAssertEqual(request.url?.absoluteString, urlString)
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.headers?["Content-Type"], "application/json")
        XCTAssertEqual(request.body as? TestBody, body)
    }
    
    func testNetworkRequestInitializationWithURL() {
        let url = URL(string: "https://example.com/api/resource")!
        let headers = ["Content-Type": "application/json"]
        let body = TestBody(key: "value")
        
        let request = NetworkRequest(url: url, method: .post, headers: headers, body: body)
        
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.headers?["Content-Type"], "application/json")
        XCTAssertEqual(request.body as? TestBody, body)
    }

    func testBodyDataEncoding() {
        let url = URL(string: "https://example.com/api/resource")!
        let body = TestBody(key: "value")
        
        let request = NetworkRequest(url: url, method: .post, headers: nil, body: body)
        
        let encodedBodyData = try? JSONEncoder().encode(body)
        XCTAssertEqual(request.bodyData, encodedBodyData)
    }

    func testBodyDataEncodingFailure() {

        let url = URL(string: "https://example.com/api/resource")!
        
        let request = NetworkRequest(url: url, method: .post, headers: nil, body: nil)
        
        XCTAssertNil(request.bodyData)
    }

    func testNoBodyData() {
        let url = URL(string: "https://example.com/api/resource")!
        
        let request = NetworkRequest(url: url, method: .post)
        
        XCTAssertNil(request.bodyData)
    }
}
