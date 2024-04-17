//  Copyright © 2024 Viacom. All rights reserved.

import Foundation

extension URLSessionDecodableError: CustomNSError {
    public static let errorDomain = "URLSessionDecodable"

    public var errorCode: Int {
        switch self {
        case .unknown: return 1
        case .urlSession: return 2
        case .deserialization: return 3
        case .nonHTTPResponse: return 4
        case .serverResponse: return 5
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case let .urlSession(error):
            return [NSUnderlyingErrorKey: error]
        case let .deserialization(deserialization):
            return deserialization.underlyingError.map {
                [NSUnderlyingErrorKey: $0]
            } ?? [:]
        case .unknown, .nonHTTPResponse, .serverResponse:
            return [:]
        }
    }
}
