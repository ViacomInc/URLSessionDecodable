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

    func testJSONEcoding() {
        let params: [String: AnyHashable] = [
            "param1": 1,
            "param2": "abc"
        ]
        let request = URLRequest(url: URL(string: "www.viacom.com/test")!)
        let encodedRequest = JSONParametersEncoder(parameters: params).encode(into: request)
        let decoded = try! JSONSerialization.jsonObject(with: encodedRequest.httpBody!) as! [String: AnyHashable]
        XCTAssertEqual(decoded, params)
    }

    static var allTests = [
        ("testURLEncoding", testURLEncoding),
        ("testJSONEcoding", testJSONEcoding),
    ]

}
