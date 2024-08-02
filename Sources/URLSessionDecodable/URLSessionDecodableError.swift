//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public enum URLSessionDecodableError: Error {
    case unknown
    case urlSession(Error)
    case deserialization(Deserialization)
    case nonHTTPResponse(URLResponse)
    case serverResponse(ServerResponse)

    public struct Deserialization: Sendable {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data
        public let underlyingError: Error?
    }

    public struct ServerResponse: Sendable {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data

        public func decode<T: Decodable>(using decoder: DataDecoder) throws -> T {
            return try decoder.decode(T.self, from: responseBody)
        }
    }

    public func decodeResponse<T: Decodable>(using decoder: DataDecoder) -> T? {
        if case .serverResponse(let serverResponse) = self {
            return try? serverResponse.decode(using: decoder)
        }
        return nil
    }
}
