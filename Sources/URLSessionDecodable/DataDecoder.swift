//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public protocol DataDecoder {

    /// Decodes an instance of the indicated type.
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable

}

// MARK: -

extension JSONDecoder: DataDecoder {}
