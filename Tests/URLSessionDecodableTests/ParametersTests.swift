import XCTest
@testable import URLSessionDecodable

final class ParametersTests: XCTestCase {

    func testURLEncoding() {
        let params = [
            "param1": "1",
            "param2": "abc"
        ]
        let request = URLRequest(url: URL(string: "www.viacom.com/test")!)
        let encodedUrl = URLParametersEncoder(parameters: params).encode(into: request).url!
        let queryItems = URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)!.queryItems!
        params.forEach { key, value in
            XCTAssert(queryItems.contains(URLQueryItem(name: key, value: value)))
        }
    }

    static var allTests = [
        ("testURLEncoding", testURLEncoding),
    ]
}
