import Foundation
import JavaScriptCore

public class JSKitEventLoop {
    public var running = false
    public var tasks = 0

    public init() {}

    public func run() {
        running = true
        while tasks > 0 && running {
            if !RunLoop.current.run(mode: .default, before: .distantPast) {
                break
            }
        }
    }

    public func perform(_ task: @escaping (
        _ completion: @escaping () -> Void
    ) throws -> Void) {
        tasks += 1
        RunLoop.current.perform(
            inModes: [.default],
            block: {
                do {
                    try task({
                        self.tasks -= 1
                    })
                } catch {
                    self.tasks -= 1
                }
            }
        )
    }

    public func performInPromise(_ task: @escaping (
        _ completion: @escaping () -> Void
    ) throws -> Void) -> JSValue {
        JSValue(
            newPromiseIn: JSContext.current(),
            fromExecutor: { resolve, reject in
                self.perform { completion in
                    do {
                        try task({
                            completion()
                            resolve!.call(withArguments: [])  
                        })
                    } catch {
                        reject!.with(rejection: "Task failed: \(error)")
                        throw error
                    }
                }
            }
        )
    }
}
