//  Copyright © 2020 Viacom. All rights reserved.

import Foundation

public protocol JSONDecodable: Decodable {
    static func decode(from data: Data) throws -> Self
    static var customDateFormatter: DateFormatter? { get }
}

extension JSONDecodable {
    public static func decode(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        if let dateFormatter = customDateFormatter {
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
        }
        return try decoder.decode(Self.self, from: data)
    }

    public static var customDateFormatter: DateFormatter? { return nil }
}
