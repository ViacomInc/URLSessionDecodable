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
    /// The response data will be decoded to `T` type when `statusCode` is in range `200..<300`.
    public func decodable<T, D: ConcreteTypeDecoder>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        decoder: D,
        completionHandler: @escaping (Result<T, URLSessionDecodableError>) -> Void
    ) -> URLSessionDataTask where D.DecodedType == T {
        return createTask(
            with: url,
            method: method,
            parameters: parameters,
            headers: headers,
            completionHandler: completionHandler
        ) { data -> T in
            try decoder.decode(data)
        }
    }

    public func decodable<T: Decodable>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        decoder: AnyTypeDecoder,
        completionHandler: @escaping (Result<T, URLSessionDecodableError>) -> Void
    ) -> URLSessionDataTask {
        return createTask(
            with: url,
            method: method,
            parameters: parameters,
            headers: headers,
            completionHandler: completionHandler
        ) { data -> T in
            try decoder.decode(T.self, from: data)
        }
    }

    private func createTask<T>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        completionHandler: @escaping (Result<T, URLSessionDecodableError>) -> Void,
        decoding: @escaping (Data) throws -> T
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
            let result = Self.handle(response: httpResponse, data: data, url: url, decoding: decoding)
            completionHandler(result)
        }
        return task
    }

    //swiftlint:enable function_parameter_count

    private static func handle<T>(
        response: HTTPURLResponse,
        data: Data,
        url: URL,
        decoding: (Data) throws -> T
    ) -> Result<T, URLSessionDecodableError> {
        guard 200..<300 ~= response.statusCode else {
            let serverResponse = URLSessionDecodableError.ServerResponse(statusCode: response.statusCode,
                                                                         url: url,
                                                                         responseBody: data)
            return .failure(.serverResponse(serverResponse))
        }

        do {
            return try .success(decoding(data))
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
