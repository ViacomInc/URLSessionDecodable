//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public enum URLSessionDecodableError<E: Decodable>: Error {
    case unknown
    case urlSession(Error)
    case parametersEncoding(Error)
    case deserialization(Deserialization)
    case nonHTTPResponse(URLResponse)
    case serverResponse(E)
    case unknownServerResponse(UnknownServerResponse)

    public struct Deserialization {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data
        public let underlyingError: Error?
    }

    public struct UnknownServerResponse {
        public let statusCode: Int
        public let url: URL
        public let responseBody: Data
    }
}
