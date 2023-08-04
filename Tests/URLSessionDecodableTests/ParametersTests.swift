import XCTest
@testable import URLSessionDecodable

final class ParametersTests: XCTestCase {

    func testURLEncoding() throws {
        let params = [
            "param1": "1",
            "param2": "abc"
        ]
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test")))
        let encodedUrl = try XCTUnwrap(URLParametersEncoder(parameters: params).encode(into: request).url)
        let queryItems = try XCTUnwrap(URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)?.queryItems)
        params.forEach { key, value in
            XCTAssert(queryItems.contains(URLQueryItem(name: key, value: value)))
        }
    }

    func testURLEncodingWithExistingParameters() throws {
        let params = [
            "param1": "1",
            "param2": "abc"
        ]
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test?param1=0&param3=foo")))
        let encodedUrl = try XCTUnwrap(URLParametersEncoder(parameters: params).encode(into: request).url)
        let queryItems = try XCTUnwrap(URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)?.queryItems)

        let expectedParameters: [String: String] = [
            "param1": "1",
            "param2": "abc",
            "param3": "foo"
        ]
        let urlParameters = queryItems.reduce(into: [:]) { dictionary, param in
            dictionary[param.name] = param.value
        }
        XCTAssertEqual(expectedParameters, urlParameters)
        XCTAssertEqual(queryItems.count, 4) // params are appended currently
    }

    func testURLEncodingWithEmptyParameters() throws{
        let params = [String: String]()
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test")))
        let encodedUrl = try XCTUnwrap(URLParametersEncoder(parameters: params).encode(into: request).url)
        XCTAssertFalse(encodedUrl.absoluteString.contains("?"))
        XCTAssertNil(encodedUrl.query)
    }

    func testJSONEcoding() throws {
        let params: [String: AnyHashable] = [
            "param1": 1,
            "param2": "abc"
        ]
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test")))
        let encodedRequest = JSONParametersEncoder(parameters: params).encode(into: request)
        let decoded = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(encodedRequest.httpBody)) as? [String: AnyHashable])
        XCTAssertEqual(decoded, params)
    }

    func testMergedEncoding() throws {
        let params = [
            "param": "test",
        ]
        let encoder = MergedParametersEncoder(encoders: [
            URLParametersEncoder(parameters: params),
            JSONParametersEncoder(parameters: params)
        ])
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test")))
        let encodedRequest = encoder.encode(into: request)
        let decoded = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(encodedRequest.httpBody)) as? [String: String])

        XCTAssertEqual(encodedRequest.url?.query, "param=test")
        XCTAssertEqual(decoded, params)
    }

    func testURLEncodingWithOrdering() throws {
        let params: [(key: String, value: CustomStringConvertible)] = [
            (key: "param2", value: 2),
            (key: "param3", value: "3"),
            (key: "param4", value: "4")
        ]
        let request = try URLRequest(url: XCTUnwrap(URL(string: "www.viacom.com/test?param1=abc")))
        let encodedUrl = try XCTUnwrap(URLParametersEncoder(parameters: params).encode(into: request).url)
        let queryItems = try XCTUnwrap(URLComponents(url: encodedUrl, resolvingAgainstBaseURL: false)?.queryItems)

        let expectedParameters: [URLQueryItem] = [
            .init(name: "param1", value: "abc"),
            .init(name: "param2", value: "2"),
            .init(name: "param3", value: "3"),
            .init(name: "param4", value: "4")
        ]
        XCTAssertEqual(queryItems, expectedParameters)
    }
}
