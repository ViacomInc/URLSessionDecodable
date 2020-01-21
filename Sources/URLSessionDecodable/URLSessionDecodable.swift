//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public typealias HTTPHeadersDictionary = [String: String]

public enum HTTPMethod: String {
    case delete
    case get
    case post
    case put
}

public enum ParameterEncoding {
    case URL
    case JSON
}

extension URLSession {

    public func decodable<T: JSONDecodable, E: Decodable>(
      method: HTTPMethod,
      URL: URL,
      parameters: [String: Any]?,
      encoding: ParameterEncoding,
      headers: HTTPHeadersDictionary,
      completionHandler: @escaping (Result<T, URLSessionDecodableError<E>>) -> Void) -> URLSessionDataTask {
        let request = self.request(method: method, URL: URL, parameters: parameters, encoding: encoding, headers: headers)
        let task = dataTask(with: request) { data, response, error in
            guard let response = response, let data = data else {
                completionHandler(.failure(URLSessionDecodableError.unknown))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(URLSessionDecodableError.nonHTTPResponse(response)))
                return
            }

            completionHandler(Self.handle(response: httpResponse, data: data, url: URL))
        }
        return task
    }

    private static func handle<T: JSONDecodable, E: Decodable>(
      response: HTTPURLResponse,
      data: Data,
      url: URL) -> Result<T, URLSessionDecodableError<E>> {
        guard 200...299 ~= response.statusCode else {
            do {
                let error = try JSONDecoder().decode(E.self, from: data)
                return .failure(.serverResponse(error))
            } catch {
                return .failure(.unknownServerResponse(URLSessionDecodableError.UnknownServerResponse(statusCode: response.statusCode, url: url, responseBody: data)))
            }
        }

        do {
            return try .success(T.decode(from: data))
        } catch {
            return .failure(.deserialization(URLSessionDecodableError.Deserialization(statusCode: response.statusCode, url: url, responseBody: data, underlyingError: error)))
        }
    }

    private func request(
      method: HTTPMethod,
      URL: URL,
      parameters: [String: Any]?,
      encoding: ParameterEncoding,
      headers: HTTPHeadersDictionary) -> URLRequest {
        let body: Data?
        var url = URL
        var headers = headers

        switch encoding {
        case .JSON:
            headers["Content-Type"] = "application/json; charset=utf-8"
            body = parameters.map { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) } ?? nil
        case .URL:
            body = nil
            var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)
            var query: [URLQueryItem] = []
            parameters?.forEach { (arg) in
                let (name, value) = arg
                query.append(URLQueryItem(name: name, value: value as? String))
            }
            components?.queryItems = query
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = body

        return request
    }

}

