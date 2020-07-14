import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ZombieDiceAppTests.allTests),
    ]
}
#endif
