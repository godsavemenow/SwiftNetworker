import XCTest
@testable import SwiftNetworker

class HTTPMethodTests: XCTestCase {
    
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }
    
    func testURLRequestHTTPMethod() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        request.httpMethod = HTTPMethod.get.rawValue
        XCTAssertEqual(request.httpMethod, "GET")
        
        request.httpMethod = HTTPMethod.patch.rawValue
        XCTAssertEqual(request.httpMethod, "PATCH")
        
        request.httpMethod = HTTPMethod.post.rawValue
        XCTAssertEqual(request.httpMethod, "POST")
        
        request.httpMethod = HTTPMethod.put.rawValue
        XCTAssertEqual(request.httpMethod, "PUT")
        
        request.httpMethod = HTTPMethod.delete.rawValue
        XCTAssertEqual(request.httpMethod, "DELETE")
    }
}
