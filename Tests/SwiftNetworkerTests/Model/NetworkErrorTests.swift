import XCTest
@testable import SwiftNetworker

class NetworkErrorTests: XCTestCase {
    
    func testInvalidURLDescription() {
        let error = NetworkError(errorCase: .invalidURL, apiErrorMessage: nil)
        XCTAssertEqual(error.detailedDescription, "The URL provided was invalid.")
    }
    
    func testNoDataDescription() {
        let error = NetworkError(errorCase: .noData, apiErrorMessage: nil)
        XCTAssertEqual(error.detailedDescription, "No data was returned from the server.")
    }
    
    func testTimeOutDescription() {
        let error = NetworkError(errorCase: .timeOut, apiErrorMessage: nil)
        XCTAssertEqual(error.detailedDescription, "The request timed out.")
    }
    
    func testBadRequestDescription() {
        let error = NetworkError(errorCase: .badRequest("Invalid parameters"), apiErrorMessage: "Parameter 'id' is missing.")
        XCTAssertEqual(error.detailedDescription, "Bad Request: Invalid parameters - Parameter 'id' is missing.")
    }
    
    func testUnauthorizedDescription() {
        let error = NetworkError(errorCase: .unauthorized("Invalid token"), apiErrorMessage: "Token expired")
        XCTAssertEqual(error.detailedDescription, "Unauthorized: Invalid token - Token expired")
    }
    
    func testForbiddenDescription() {
        let error = NetworkError(errorCase: .forbidden("Access denied"), apiErrorMessage: "You do not have permission to access this resource.")
        XCTAssertEqual(error.detailedDescription, "Forbidden: Access denied - You do not have permission to access this resource.")
    }
    
    func testNotFoundDescription() {
        let error = NetworkError(errorCase: .notFound("Resource not found"), apiErrorMessage: "The requested resource could not be found.")
        XCTAssertEqual(error.detailedDescription, "Not Found: Resource not found - The requested resource could not be found.")
    }
    
    func testServerErrorDescription() {
        let error = NetworkError(errorCase: .serverError("Internal server error"), apiErrorMessage: "Unexpected error occurred.")
        XCTAssertEqual(error.detailedDescription, "Server Error: Internal server error - Unexpected error occurred.")
    }
    
    func testParsingErrorDescription() {
        let error = NetworkError(errorCase: .parsingError("JSON parsing error"), apiErrorMessage: "Could not parse the response.")
        XCTAssertEqual(error.detailedDescription, "Parsing Error: JSON parsing error - Could not parse the response.")
    }
    
    func testRequestCanceledDescription() {
        let error = NetworkError(errorCase: .requestCanceled("Request was canceled"), apiErrorMessage: "User canceled the request.")
        XCTAssertEqual(error.detailedDescription, "Request Canceled: Request was canceled - User canceled the request.")
    }
    
    func testDecodingErrorDescription() {
        let error = NetworkError(errorCase: .decodingError("Decoding failed"), apiErrorMessage: "Failed to decode the response.")
        XCTAssertEqual(error.detailedDescription, "Decoding Error: Decoding failed - Failed to decode the response.")
    }
    
    func testNetworkErrorDescription() {
        let nsError = NSError(domain: "Network", code: 404, userInfo: nil)
        let error = NetworkError(errorCase: .networkError(nsError), apiErrorMessage: nil)
        XCTAssertEqual(error.detailedDescription, "Network Error: The operation couldn’t be completed. (Network error 404.)")
    }
    
    func testUnknownErrorDescription() {
        let nsError = NSError(domain: "Unknown", code: 0, userInfo: nil)
        let error = NetworkError(errorCase: .unknown(nsError), apiErrorMessage: nil)
        XCTAssertEqual(error.detailedDescription, "Unknown Error: The operation couldn’t be completed. (Unknown error 0.)")
    }
    
    func testMultipleChoicesDescription() {
        let error = NetworkError(errorCase: .multipleChoices("Multiple options available"), apiErrorMessage: "Choose one of the options.")
        XCTAssertEqual(error.detailedDescription, "Multiple Choices: Multiple options available - Choose one of the options.")
    }
    
    func testMovedPermanentlyDescription() {
        let error = NetworkError(errorCase: .movedPermanently("Resource moved permanently"), apiErrorMessage: "The resource has been moved to a new URL.")
        XCTAssertEqual(error.detailedDescription, "Moved Permanently: Resource moved permanently - The resource has been moved to a new URL.")
    }
    
    func testFoundDescription() {
        let error = NetworkError(errorCase: .found("Resource found"), apiErrorMessage: "The resource is available at a different URL.")
        XCTAssertEqual(error.detailedDescription, "Found: Resource found - The resource is available at a different URL.")
    }
    
    func testSeeOtherDescription() {
        let error = NetworkError(errorCase: .seeOther("See other resource"), apiErrorMessage: "Please refer to the other resource.")
        XCTAssertEqual(error.detailedDescription, "See Other: See other resource - Please refer to the other resource.")
    }
    
    func testNotModifiedDescription() {
        let error = NetworkError(errorCase: .notModified("Resource not modified"), apiErrorMessage: "The resource has not been modified.")
        XCTAssertEqual(error.detailedDescription, "Not Modified: Resource not modified - The resource has not been modified.")
    }
    
    func testUseProxyDescription() {
        let error = NetworkError(errorCase: .useProxy("Use proxy server"), apiErrorMessage: "Access the resource through the proxy server.")
        XCTAssertEqual(error.detailedDescription, "Use Proxy: Use proxy server - Access the resource through the proxy server.")
    }
    
    func testTemporaryRedirectDescription() {
        let error = NetworkError(errorCase: .temporaryRedirect("Temporary redirect"), apiErrorMessage: "The resource is temporarily available at a different URL.")
        XCTAssertEqual(error.detailedDescription, "Temporary Redirect: Temporary redirect - The resource is temporarily available at a different URL.")
    }
    
    func testPermanentRedirectDescription() {
        let error = NetworkError(errorCase: .permanentRedirect("Permanent redirect"), apiErrorMessage: "The resource is permanently available at a different URL.")
        XCTAssertEqual(error.detailedDescription, "Permanent Redirect: Permanent redirect - The resource is permanently available at a different URL.")
    }
}
