import XCTest
@testable import SwiftNetworker

class NetworkErrorCasesTests: XCTestCase {

    func testInvalidURLDescription() {
        let error = NetworkErrorCases.invalidURL
        XCTAssertEqual(error.description, "The URL provided was invalid.")
    }

    func testNoDataDescription() {
        let error = NetworkErrorCases.noData
        XCTAssertEqual(error.description, "No data was returned from the server.")
    }

    func testTimeOutDescription() {
        let error = NetworkErrorCases.timeOut
        XCTAssertEqual(error.description, "The request timed out.")
    }

    func testLockedDescription() {
        let error = NetworkErrorCases.locked
        XCTAssertEqual(error.description, "The networker is locked.")
    }

    func testBadRequestDescription() {
        let error = NetworkErrorCases.badRequest("Invalid parameters")
        XCTAssertEqual(error.description, "Bad Request: Invalid parameters")
    }

    func testUnauthorizedDescription() {
        let error = NetworkErrorCases.unauthorized("No token provided")
        XCTAssertEqual(error.description, "Unauthorized: No token provided")
    }

    func testForbiddenDescription() {
        let error = NetworkErrorCases.forbidden("Access denied")
        XCTAssertEqual(error.description, "Forbidden: Access denied")
    }

    func testNotFoundDescription() {
        let error = NetworkErrorCases.notFound("Resource not found")
        XCTAssertEqual(error.description, "Not Found: Resource not found")
    }

    func testServerErrorDescription() {
        let error = NetworkErrorCases.serverError("Internal server error")
        XCTAssertEqual(error.description, "Server Error: Internal server error")
    }

    func testParsingErrorDescription() {
        let error = NetworkErrorCases.parsingError("Unable to parse JSON")
        XCTAssertEqual(error.description, "Parsing Error: Unable to parse JSON")
    }

    func testRequestCanceledDescription() {
        let error = NetworkErrorCases.requestCanceled("User canceled the request")
        XCTAssertEqual(error.description, "Request Canceled: User canceled the request")
    }

    func testDecodingErrorDescription() {
        let error = NetworkErrorCases.decodingError("Failed to decode response")
        XCTAssertEqual(error.description, "Decoding Error: Failed to decode response")
    }

    func testNetworkErrorDescription() {
        let underlyingError = NSError(domain: "Network", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network is unreachable"])
        let error = NetworkErrorCases.networkError(underlyingError)
        XCTAssertEqual(error.description, "Network Error: Network is unreachable")
    }

    func testUnknownErrorDescription() {
        let underlyingError = NSError(domain: "Unknown", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        let error = NetworkErrorCases.unknown(underlyingError)
        XCTAssertEqual(error.description, "Unknown Error: Something went wrong")
    }

    func testMultipleChoicesDescription() {
        let error = NetworkErrorCases.multipleChoices("Multiple resources available")
        XCTAssertEqual(error.description, "Multiple Choices: Multiple resources available")
    }

    func testMovedPermanentlyDescription() {
        let error = NetworkErrorCases.movedPermanently("Resource moved to a new location")
        XCTAssertEqual(error.description, "Moved Permanently: Resource moved to a new location")
    }

    func testFoundDescription() {
        let error = NetworkErrorCases.found("Resource found at a different location")
        XCTAssertEqual(error.description, "Found: Resource found at a different location")
    }

    func testSeeOtherDescription() {
        let error = NetworkErrorCases.seeOther("See other resource at a different location")
        XCTAssertEqual(error.description, "See Other: See other resource at a different location")
    }

    func testNotModifiedDescription() {
        let error = NetworkErrorCases.notModified("Resource not modified since last request")
        XCTAssertEqual(error.description, "Not Modified: Resource not modified since last request")
    }

    func testUseProxyDescription() {
        let error = NetworkErrorCases.useProxy("Use proxy at a different location")
        XCTAssertEqual(error.description, "Use Proxy: Use proxy at a different location")
    }

    func testTemporaryRedirectDescription() {
        let error = NetworkErrorCases.temporaryRedirect("Temporary redirect to a different location")
        XCTAssertEqual(error.description, "Temporary Redirect: Temporary redirect to a different location")
    }

    func testPermanentRedirectDescription() {
        let error = NetworkErrorCases.permanentRedirect("Permanent redirect to a new location")
        XCTAssertEqual(error.description, "Permanent Redirect: Permanent redirect to a new location")
    }
}
