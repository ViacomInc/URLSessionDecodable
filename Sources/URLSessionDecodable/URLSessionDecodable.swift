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

    /// Creates a task that retrieves the contents of the specified URL, decodes the response,
    /// then calls a handler upon completion.
    ///
    /// The response data will be decoded to `T` type when `statusCode` is in range `200..<300`
    /// or `E` for other status codes.
    public func decodable<T: Decodable, E: Decodable>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders,
        decoder: DataDecoder,
        completionHandler: @escaping (Result<T, URLSessionDecodableError<E>>) -> Void
    ) -> URLSessionDataTask {
        let request = self.request(with: url, method: method, parameters: parameters, headers: headers)
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

            completionHandler(Self.handle(response: httpResponse, data: data, decoder: decoder, url: url))
        }
        return task
    }

    private static func handle<T: Decodable, E: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        decoder: DataDecoder,
        url: URL
    ) -> Result<T, URLSessionDecodableError<E>> {
        guard 200..<300 ~= response.statusCode else {
            do {
                let error = try decoder.decode(E.self, from: data)
                return .failure(.serverResponse(error))
            } catch {
                return .failure(.unknownServerResponse(URLSessionDecodableError.UnknownServerResponse(statusCode: response.statusCode, url: url, responseBody: data)))
            }
        }

        do {
            return try .success(decoder.decode(T.self, from: data))
        } catch {
            return .failure(.deserialization(URLSessionDecodableError.Deserialization(statusCode: response.statusCode, url: url, responseBody: data, underlyingError: error)))
        }
    }

    private func request(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue

        if let parameters = parameters {
            request = parameters.encode(into: request)
        }

        return request
    }

}
