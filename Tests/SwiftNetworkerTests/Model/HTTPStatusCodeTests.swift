import XCTest
@testable import SwiftNetworker

class HTTPStatusCodeTests: XCTestCase {
    
    func testIsSuccessful() {
        XCTAssertTrue(HTTPStatusCode.isSuccessful(200))
        XCTAssertTrue(HTTPStatusCode.isSuccessful(201))
        XCTAssertTrue(HTTPStatusCode.isSuccessful(299))
        XCTAssertFalse(HTTPStatusCode.isSuccessful(300))
        XCTAssertFalse(HTTPStatusCode.isSuccessful(199))
    }
    
    func testIsRedirection() {
        XCTAssertTrue(HTTPStatusCode.isRedirection(300))
        XCTAssertTrue(HTTPStatusCode.isRedirection(301))
        XCTAssertTrue(HTTPStatusCode.isRedirection(399))
        XCTAssertFalse(HTTPStatusCode.isRedirection(400))
        XCTAssertFalse(HTTPStatusCode.isRedirection(299))
    }
    
    func testIsClientError() {
        XCTAssertTrue(HTTPStatusCode.isClientError(400))
        XCTAssertTrue(HTTPStatusCode.isClientError(401))
        XCTAssertTrue(HTTPStatusCode.isClientError(499))
        XCTAssertFalse(HTTPStatusCode.isClientError(500))
        XCTAssertFalse(HTTPStatusCode.isClientError(399))
    }
    
    func testIsServerError() {
        XCTAssertTrue(HTTPStatusCode.isServerError(500))
        XCTAssertTrue(HTTPStatusCode.isServerError(501))
        XCTAssertTrue(HTTPStatusCode.isServerError(599))
        XCTAssertFalse(HTTPStatusCode.isServerError(600))
        XCTAssertFalse(HTTPStatusCode.isServerError(499))
    }
    
    func testFrom() {
        XCTAssertEqual(HTTPStatusCode.from(200), .ok)
        XCTAssertEqual(HTTPStatusCode.from(201), .created)
        XCTAssertEqual(HTTPStatusCode.from(301), .movedPermanently)
        XCTAssertEqual(HTTPStatusCode.from(404), .notFound)
        XCTAssertEqual(HTTPStatusCode.from(500), .internalServerError)
        XCTAssertNil(HTTPStatusCode.from(100))
        XCTAssertNil(HTTPStatusCode.from(600))
    }
}
