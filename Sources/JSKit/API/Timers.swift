import JavaScriptCore

var timerID = 0

let setTimeout: @convention(block) (JSValue, Int) -> Int = { callback, timeout in
    timerID += 1
    let id = timerID
    callback.context.runtime.eventLoop.perform { completion in
        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeout) / 1000, repeats: false) { _ in
            callback.call(withArguments: nil)
            completion()
        }
    }
    return id
}

public func initTimersAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
}
