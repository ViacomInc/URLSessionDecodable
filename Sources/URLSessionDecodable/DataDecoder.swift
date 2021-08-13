//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public protocol AnyTypeDecoder {

    /// Decodes an instance of the indicated type.
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable

}

// For legacy reasons
public typealias DataDecoder = AnyTypeDecoder

public protocol ConcreteTypeDecoder {

    associatedtype DecodedType

    /// Decodes an instance of the indicated type.
    func decode(_ data: Data) throws -> DecodedType

}

// MARK: -

extension JSONDecoder: AnyTypeDecoder {}
