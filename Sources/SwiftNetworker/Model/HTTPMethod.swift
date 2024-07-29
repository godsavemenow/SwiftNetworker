import Foundation

/// An enumeration representing HTTP methods.
public enum HTTPMethod: String {
    /// The GET method requests a representation of the specified resource.
    case get = "GET"
    
    /// The PATCH method is used to apply partial modifications to a resource.
    case patch = "PATCH"
    
    /// The POST method is used to submit an entity to the specified resource.
    case post = "POST"
    
    /// The PUT method replaces all current representations of the target resource with the request payload.
    case put = "PUT"
    
    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"
}
