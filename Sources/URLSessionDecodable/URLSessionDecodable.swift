//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPMethod: String {
    case delete
    case get
    case post
    case put
}

extension URLSession {

    public func decodable<T: JSONDecodable, E: Decodable>(
        method: HTTPMethod,
        URL: URL,
        parameters: Parameters?,
        headers: HTTPHeaders,
        completionHandler: @escaping (Result<T, URLSessionDecodableError<E>>) -> Void
    ) -> URLSessionDataTask? {
        let request = self.request(method: method, URL: URL, parameters: parameters, headers: headers)
        let task = dataTask(with: request) { data, response, error in
            guard let response = response, let data = data else {
                if let error = error {
                    completionHandler(.failure(URLSessionDecodableError.urlSession(error)))
                } else {
                    completionHandler(.failure(URLSessionDecodableError.unknown))
                }
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
        url: URL
    ) -> Result<T, URLSessionDecodableError<E>> {
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
        parameters: Parameters?,
        headers: HTTPHeaders
    ) -> URLRequest {
        var request = URLRequest(url: URL)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue

        if let parameters = parameters {
            request = parameters.encoder.encode(into: request)
        }

        return request
    }

}
