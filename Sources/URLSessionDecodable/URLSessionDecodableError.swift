//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public enum URLSessionDecodableError: Error {
    case unknown
    case urlSession(Error)
    case deserialization(Deserialization)
    case nonHTTPResponse(URLResponse)
    case serverResponse(ServerResponse)

    public struct Deserialization {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data
        public let underlyingError: Error?
        
        public init(statusCode: Int, url: URL, responseBody: Data, underlyingError: Error?) {
            self.statusCode = statusCode
            self.url = url
            self.responseBody = responseBody
            self.underlyingError = underlyingError
        }
    }

    public struct ServerResponse {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data
        
        public init(statusCode: Int, url: URL, responseBody: Data) {
            self.statusCode = statusCode
            self.url = url
            self.responseBody = responseBody
        }

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
