//  Copyright © 2020 Viacom. All rights reserved.

import Foundation
import os.log

public typealias HTTPHeaders = [String: String]

public enum HTTPMethod: String {
    case delete
    case get
    case post
    case put
}

extension URLSession {
    //swiftlint:disable function_parameter_count
    /// Creates a task that retrieves the contents of the specified URL, decodes the response,
    /// then calls a handler upon completion.
    ///
    /// The response data will be decoded to `T` type when `statusCode` is in range `200..<300`
    /// or `E` for other status codes.
    public func decodable<T: Decodable>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        decoder: DataDecoder,
        completionHandler: @escaping (Result<T, URLSessionDecodableError>) -> Void
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
    //swiftlint:enable function_parameter_count

    private static func handle<T: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        decoder: DataDecoder,
        url: URL
    ) -> Result<T, URLSessionDecodableError> {
        guard 200..<300 ~= response.statusCode else {
            let serverResponse = URLSessionDecodableError.ServerResponse(statusCode: response.statusCode,
                                                                         url: url,
                                                                         responseBody: data)
            return .failure(.serverResponse(serverResponse))
        }

        do {
            return try .success(decoder.decode(T.self, from: data))
        } catch {
            if #available(iOS 10.0, *) {
                os_log("%@", "Error while decoding \(String(describing: type(of: T.self))) \(error)")
            }
            let deserializationError = URLSessionDecodableError.Deserialization(statusCode: response.statusCode,
                                                                                url: url, responseBody: data,
                                                                                underlyingError: error)
            return .failure(.deserialization(deserializationError))
        }
    }

    private func request(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?
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
