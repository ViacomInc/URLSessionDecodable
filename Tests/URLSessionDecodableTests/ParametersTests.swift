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

    func testURLEncodingWithExistingParameters() {
        let params = [
            "param1": "1",
            "param2": "abc"
        ]
        let request = URLRequest(url: URL(string: "www.viacom.com/test?param1=0&param3=foo")!)
        let encodedUrl = URLParametersEncoder(parameters: params).encode(into: request).url!
        let queryItems = URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)!.queryItems!

        let expectedParameters: [String: String] = [
            "param1": "1",
            "param2": "abc",
            "param3": "foo"
        ]
        let urlParameters = queryItems.reduce([String:String]()) { dict, param in
            var dict = dict
            dict[param.name] = param.value
            return dict
        }
        XCTAssertEqual(expectedParameters, urlParameters)
    }

    func testURLEncodingWithEmptyParameters() {
        let params = [String: String]()
        let request = URLRequest(url: URL(string: "www.viacom.com/test")!)
        let encodedUrl = URLParametersEncoder(parameters: params).encode(into: request).url!
        XCTAssertFalse(encodedUrl.absoluteString.contains("?"))
        XCTAssertNil(encodedUrl.query)
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

}
