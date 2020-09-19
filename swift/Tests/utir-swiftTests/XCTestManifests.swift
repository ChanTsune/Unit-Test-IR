import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(utir_swiftTests.allTests),
    ]
}
#endif
