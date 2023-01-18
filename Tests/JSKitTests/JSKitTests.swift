import XCTest
@testable import JSKit

final class JSKitTests: XCTestCase {
    func testExample() throws {
        let runtime = JSKitRuntime()
        try runtime.evaluateModule(URL(fileURLWithPath: "./module.js"), { exports, error in
            print("exports: \(exports != nil)")
            print("error: \(error != nil ? "\(error)" : "nil")")
        })
        runtime.eventLoop.run()
    }
}
