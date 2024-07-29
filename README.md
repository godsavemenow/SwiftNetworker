# SwiftNetworker

SwiftNetworker is a lightweight and powerful networking library written in Swift. It provides a simple interface for making network requests and handling responses, making it easy to integrate into your Swift projects.

## Features

- Simple and intuitive API
- Supports GET, POST, PUT, DELETE, and custom HTTP methods
- Handles JSON encoding and decoding
- Supports URL parameters and request bodies
- Customizable request headers
- Automatic error handling
- Supports Swift Concurrency (async/await)

## Installation

### Swift Package Manager

To add SwiftNetworker to your project, use Swift Package Manager. Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/godsavemenow/SwiftNetworker.git", from: "1.0.0")
]
```

Then, include `"SwiftNetworker"` as a dependency in your target:

```swift
.target(
    name: "YourTargetName",
    dependencies: ["SwiftNetworker"]
)
```

## Usage

### Importing the Library

First, import SwiftNetworker into your Swift file:

```swift
import SwiftNetworker
```

### Creating a Networker Instance

Create an instance of the `Networker` class:

```swift
let networker = Networker()
```

### Making a Request

You can make network requests using the `request` method. Here’s an example of a GET request:

```swift
do {
    let response: YourResponseType = try await networker.request(
        url: URL(string: "https://api.example.com/data")!,
        method: .get,
        responseType: YourResponseType.self
    )
    print(response)
} catch {
    print("Request failed with error: \(error)")
}
```

### HTTP Methods

SwiftNetworker supports various HTTP methods. Here are examples of each:

#### GET

```swift
let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .get,
    responseType: YourResponseType.self
)
```

#### POST

```swift
let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .post,
    body: YourRequestBodyType(...),
    responseType: YourResponseType.self
)
```

#### PUT

```swift
let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .put,
    body: YourRequestBodyType(...),
    responseType: YourResponseType.self
)
```

#### DELETE

```swift
let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .delete,
    responseType: YourResponseType.self
)
```

### Customizing Requests

You can customize your requests by adding headers and URL parameters:

```swift
let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .get,
    headers: ["Authorization": "Bearer token"],
    parameters: ["query": "value"],
    responseType: YourResponseType.self
)
```

### Handling Responses

SwiftNetworker automatically decodes JSON responses into the specified response type:

```swift
struct YourResponseType: Codable {
    let id: Int
    let name: String
}

let response: YourResponseType = try await networker.request(
    url: URL(string: "https://api.example.com/data")!,
    method: .get,
    responseType: YourResponseType.self
)
print(response.id, response.name)
```

### Sending Parameters and Receiving Response

To send parameters and receive a response using `YourResponseType`, you can use the following example:

```swift
struct YourRequestBodyType: Codable {
    let param1: String
    let param2: Int
}

struct YourResponseType: Codable {
    let result: String
    let status: Int
}

let requestBody = YourRequestBodyType(param1: "value1", param2: 123)

do {
    let response: YourResponseType = try await networker.request(
        url: URL(string: "https://api.example.com/data")!,
        method: .post,
        body: requestBody,
        responseType: YourResponseType.self
    )
    print(response.result, response.status)
} catch {
    print("Request failed with error: \(error)")
}
```

### Error Handling

Errors are thrown for network or decoding failures. Handle them using Swift’s `do-catch` syntax:

```swift
do {
    let response: YourResponseType = try await networker.request(
        url: URL(string: "https://api.example.com/data")!,
        method: .get,
        responseType: YourResponseType.self
    )
    print(response)
} catch {
    print("Request failed with error: \(error)")
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

SwiftNetworker is licensed under the MIT License. See the [LICENSE](https://github.com/godsavemenow/SwiftNetworker/blob/main/LICENSE) file for more information.

## Acknowledgments

Thanks to the Swift community for their continuous support and contributions.
