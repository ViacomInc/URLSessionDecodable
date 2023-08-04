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
public struct URLParametersEncoder<Parameters>: ParametersEncoding where Parameters: Collection<(key: String, value: String)> {

    public let parameters: Parameters

    /// Creates a new encoder.
    ///
    /// Any `CustomStringConvertible` parameters are supported now.
    ///
    /// - Parameter parameters: A collection of parameters.
    public init(parameters: Parameters) {
        self.parameters = parameters
    }

    public func encode(into urlRequest: URLRequest) -> URLRequest {
        guard !parameters.isEmpty, let url = urlRequest.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return urlRequest
        }
        let query = components.queryItems ?? []
        let newQueryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value.description) }
        components.queryItems = query + newQueryItems

        guard let urlWithQuery = components.url else { return urlRequest }

        var request = urlRequest
        request.url = urlWithQuery
        return request
    }

}

// MARK: -

private enum ContentType: String {
    case json = "application/json; charset=utf-8"
}

// MARK: - Merged Parameters Encoder

/// Merges multiple encoders into one URL request.
///
/// Encoders will encode in the order of the array. Any potential encoding conflicts will be ignored.
public struct MergedParametersEncoder: ParametersEncoding {

    /// The encoders to merge.
    public let encoders: [ParametersEncoding]

    /// Creates a new encoder.
    ///
    /// - Parameter encoders: The encoders to merge.
    public init(encoders: [ParametersEncoding]) {
        self.encoders = encoders
    }

    public func encode(into urlRequest: URLRequest) -> URLRequest {
        encoders.reduce(urlRequest) { (urlRequest, encoder: ParametersEncoding) -> URLRequest in
            encoder.encode(into: urlRequest)
        }
    }

}
