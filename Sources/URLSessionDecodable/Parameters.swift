//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public protocol ParametersEncoding {

    /// Encodes data into `urlRequest`.
    ///
    /// Implementations of this method have to perform all required modifications to `urlRequest` and then return
    /// the modified request.
    ///
    /// Initial `url` and `allHTTPHeaderFields` will be already set.
    ///
    /// - Parameter urlRequest: The request to modify
    /// - Returns: A modified instance of `URLRequest`
    func encode(into urlRequest: URLRequest) -> URLRequest

}

// MARK: - JSON Encoding

/// Encodes parameters into _body_ as JSON.
public struct JSONParametersEncoder: ParametersEncoding {

    public let parameters: [String: Any]

    /// Creates a new encoder.
    ///
    /// - Attention: If `parameters` cannot be encoded as JSON then they will be ignored.
    ///
    /// - Parameter parameters: A dictionary of encodable parameters.
    public init(parameters: [String: Any]) {
        self.parameters = parameters
    }

    public func encode(into urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.allHTTPHeaderFields?["Content-Type"] = ContentType.json.rawValue
        return request
    }

}

// MARK: - URL Encoding

/// Encodes parameters adding them to the URL.
public struct URLParametersEncoder: ParametersEncoding {

    public let parameters: [String: String]

    /// Creates a new encoder.
    ///
    /// - Attention: Only `String` parameters are supported now.
    ///
    /// - Parameter parameters: A dictionary of parameters.
    public init(parameters: [String: String]) {
        self.parameters = parameters
    }

    public func encode(into urlRequest: URLRequest) -> URLRequest {
        guard !parameters.isEmpty, let url = urlRequest.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return urlRequest
        }

        var request = urlRequest
        var query: [URLQueryItem] = []
        parameters.forEach { name, value in
            query.append(URLQueryItem(name: name, value: value))
        }
        components.queryItems = query
        if let urlWithQuery = components.url {
            request.url = urlWithQuery
        }

        return request
    }

}

// MARK: -

private enum ContentType: String {
    case json = "application/json; charset=utf-8"
}
