//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public protocol DataDecoder {

    /// Decodes an instance of the indicated type.
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable

}

// MARK: -

extension JSONDecoder: DataDecoder {}

// MARK: -

public struct StringDecoder: DataDecoder {

    public var encoding: String.Encoding = .utf8

    public enum DecodingError: Error {
        case decoding
        case notStringType
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let string = String(data: data, encoding: encoding) else {
            throw DecodingError.decoding
        }
        guard let castString = string as? T else {
            throw DecodingError.notStringType
        }
        return castString
    }

}
