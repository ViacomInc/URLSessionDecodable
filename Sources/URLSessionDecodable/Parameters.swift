//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public enum Parameters {
    case url([String: String])
    case json([String: Any])
    case data(data: Data, contentType: String)
    case custom(encoder: ParametersEncoding)
}

public struct Body {
    public let contentType: String
    public let data: Data
}

public protocol ParametersEncoding {
    func encode(into urlRequest: URLRequest) -> URLRequest
}

// MARK: -

extension Parameters {

    var encoder: ParametersEncoding {
        switch self {
        case .url(let parameters):
            return URLParametersEncoder(parameters: parameters)
        case .json(let parameters):
            return JSONParametersEncoder(parameters: parameters)
        case .data(let data, let contentType):
            return DataParametersEncoder(data: data, contentType: contentType)
        case .custom(let encoder):
            return encoder
        }
    }

}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
}

struct JSONParametersEncoder: ParametersEncoding {

    let parameters: [String: Any]

    func encode(into urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        request.allHTTPHeaderFields?["Content-Type"] = ContentType.json.rawValue
        return request
    }

}

struct URLParametersEncoder: ParametersEncoding {

    let parameters: [String: String]

    func encode(into urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        guard let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return request
        }

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

struct DataParametersEncoder: ParametersEncoding {

    let data: Data
    let contentType: String

    func encode(into urlRequest: URLRequest) -> URLRequest {
        var request = urlRequest
        request.httpBody = data
        request.allHTTPHeaderFields?["Content-Type"] = contentType
        return request
    }

}
