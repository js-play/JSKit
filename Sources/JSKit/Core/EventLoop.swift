import Foundation
import JavaScriptCore

var timerID = 1

public class JSKitEventLoop {
    public var running = false
    public var tasks = 0
    public var timers: [Int: Timer] = [:]

    public init() {}

    public func run() {
        running = true
        while (tasks > 0 || timers.count > 0) && running {
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
                            resolve!.call()  
                        })
                    } catch {
                        reject!.with(rejection: "Task failed: \(error)")
                        throw error
                    }
                }
            }
        )
    }

    public func addTimer(
        _ interval: TimeInterval,
        _ repeats: Bool,
        _ task: @escaping () -> Void
    ) -> Int {
        let id = timerID
        timerID += 1
        let timer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: repeats,
            block: { _ in
                task()
                if !repeats {
                    self.timers.removeValue(forKey: id)
                }
            }
        )
        timers[id] = timer
        RunLoop.current.add(timer, forMode: .default)
        return id
    }

    public func removeTimer(_ id: Int) {
        if let timer = timers[id] {
            timer.invalidate()
            timers.removeValue(forKey: id)
        }
    }
}
