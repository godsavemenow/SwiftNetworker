import Foundation

/// An enumeration representing HTTP methods.
///
/// ## Overview
/// The `HTTPMethod` enumeration defines the most commonly used HTTP methods for performing network requests. Each case in this enumeration
/// represents a specific type of HTTP request method, such as GET, POST, PUT, PATCH, and DELETE. These methods are used to interact with web
/// servers and perform various operations on resources.
///
/// This enumeration provides a convenient way to specify the HTTP method for a network request. By using the raw values associated with each
/// case, developers can easily set the HTTP method of a `URLRequest` object.
///
/// ## Usage
/// To use the `HTTPMethod` enumeration, simply assign one of its cases to the `httpMethod` property of a `URLRequest` object. For example:
///
/// ```swift
/// var request = URLRequest(url: URL(string: "https://example.com")!)
/// request.httpMethod = HTTPMethod.get.rawValue
/// ```
///
/// ## Cases
public enum HTTPMethod: String {
    /// The GET method requests a representation of the specified resource.
    ///
    /// This method is used to retrieve data from a server. It is a read-only operation and does not modify the resource.
    case get = "GET"
    
    /// The PATCH method is used to apply partial modifications to a resource.
    ///
    /// This method is used to update partial data of a resource on the server. It is often used when only a few fields of a resource need to be updated.
    case patch = "PATCH"
    
    /// The POST method is used to submit an entity to the specified resource.
    ///
    /// This method is used to create a new resource on the server. It is commonly used for submitting form data or uploading files.
    case post = "POST"
    
    /// The PUT method replaces all current representations of the target resource with the request payload.
    ///
    /// This method is used to update or create a resource on the server. It replaces the entire resource with the data provided in the request.
    case put = "PUT"
    
    /// The DELETE method deletes the specified resource.
    ///
    /// This method is used to delete a resource from the server. It is a write operation that removes the resource identified by the URL.
    case delete = "DELETE"
}
