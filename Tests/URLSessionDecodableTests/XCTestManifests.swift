import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(URLSessionDecodableTests.allTests),
        testCase(ParametersTests.allTests),
    ]
}
#endif
