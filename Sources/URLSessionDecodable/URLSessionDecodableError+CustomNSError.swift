//  Copyright © 2024 Viacom. All rights reserved.

import Foundation

extension URLSessionDecodableError: CustomNSError {
    public static let errorDomain = "URLSessionDecodable"

    public var errorCode: Int {
        switch self {
        case .unknown: 1
        case .urlSession: 2
        case .deserialization: 3
        case .nonHTTPResponse: 4
        case .serverResponse: 5
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case let .urlSession(error):
            [NSUnderlyingErrorKey: error]
        case let .deserialization(deserialization):
            deserialization.underlyingError.map {
                [NSUnderlyingErrorKey: $0]
            } ?? [:]
        case .unknown, .nonHTTPResponse, .serverResponse:
            [:]
        }
    }
}
