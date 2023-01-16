import XCTest
@testable import JSKit

final class JSKitTests: XCTestCase {
    func testExample() throws {
        let runtime = JSKitRuntime()
        let _ = try runtime.evaluateModule(URL(fileURLWithPath: "./module.js"))
        runtime.eventLoop.run()
    }
}
