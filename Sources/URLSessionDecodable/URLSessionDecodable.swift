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
    public func decodable<T: Decodable>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        decoder: @autoclosure @escaping @Sendable () -> DataDecoder,
        completionHandler: @escaping @Sendable (Result<T, URLSessionDecodableError>) -> Void
    ) -> URLSessionDataTask {
        let request = self.request(with: url, method: method, parameters: parameters, headers: headers)
        let task = dataTask(with: request) { data, response, error in
            guard let response = response, let data = data else {
                if let error = error {
                    os_log("%@", "Error while requesting \(String(describing: type(of: T.self))) \(url) - \(error)")
                    completionHandler(.failure(URLSessionDecodableError.urlSession(error)))
                } else {
                    os_log("%@", "Unknown error while requesting \(url)))")
                    completionHandler(.failure(URLSessionDecodableError.unknown))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                os_log("%@", "Non-http response \(String(describing: type(of: T.self))) \(url) - \(response)")
                completionHandler(.failure(URLSessionDecodableError.nonHTTPResponse(response)))
                return
            }

            completionHandler(Self.handle(response: httpResponse, data: data, decoder: decoder(), url: url))
        }
        return task
    }
    //swiftlint:enable function_parameter_count

    /// Retrieves the contents of the specified URL and returns decoded response.
    ///
    /// The response data will be decoded to `T` type when `statusCode` is in range `200..<300`.
    @available(iOS 13.0.0, tvOS 13.0.0, macOS 10.15.0, watchOS 8.0, *)
    public func decodable<T: Decodable>(
        with url: URL,
        method: HTTPMethod,
        parameters: ParametersEncoding?,
        headers: HTTPHeaders?,
        decoder: @autoclosure @Sendable () -> DataDecoder
    ) async throws -> T {
        let request = self.request(with: url, method: method, parameters: parameters, headers: headers)
        let (data, response) = try await data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            os_log("%@", "Non-http response \(String(describing: type(of: T.self))) \(url) - \(response)")
            throw URLSessionDecodableError.nonHTTPResponse(response)
        }
        return try Self.handle(response: httpResponse, data: data, decoder: decoder(), url: url).get()
    }

    // MARK: - Private

    private static func handle<T: Decodable>(
        response: HTTPURLResponse,
        data: Data,
        decoder: @autoclosure @Sendable () -> DataDecoder,
        url: URL
    ) -> Result<T, URLSessionDecodableError> {
        guard 200..<300 ~= response.statusCode else {
            let serverResponse = URLSessionDecodableError.ServerResponse(statusCode: response.statusCode,
                                                                         url: url,
                                                                         responseBody: data)
            return .failure(.serverResponse(serverResponse))
        }

        do {
            return try .success(decoder().decode(T.self, from: data))
        } catch {
            os_log("%@", "Error while decoding \(String(describing: type(of: T.self))) \(error)")
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
