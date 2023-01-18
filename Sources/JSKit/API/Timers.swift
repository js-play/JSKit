import JavaScriptCore

let setTimeout: @convention(block) (JSValue, Int) -> Int = { callback, timeout in
    return JSKitRuntime.current.eventLoop.addTimer(
        TimeInterval(timeout) / 1000,
        false,
        {
            callback.call(withArguments: nil)
        }
    )
}

let setInterval: @convention(block) (JSValue, Int) -> Int = { callback, timeout in
    return JSKitRuntime.current.eventLoop.addTimer(
        TimeInterval(timeout) / 1000,
        true,
        {
            callback.call(withArguments: nil)
        }
    )
}

let clearTimeout: @convention(block) (Int) -> Void = { timerId in
    JSKitRuntime.current.eventLoop.removeTimer(timerId)
}

let clearInterval: @convention(block) (Int) -> Void = { timerId in
    JSKitRuntime.current.eventLoop.removeTimer(timerId)
}

let setImmediate: @convention(block) (JSValue) -> Int = { callback in
    return setTimeout(callback, 0)
}

let clearImmediate: @convention(block) (Int) -> Void = { timerId in
    clearTimeout(timerId)
}

public func initTimersAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
    rt.globalContext.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)
    rt.globalContext.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)
    rt.globalContext.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)
    rt.globalContext.setObject(setImmediate, forKeyedSubscript: "setImmediate" as NSString)
    rt.globalContext.setObject(clearImmediate, forKeyedSubscript: "clearImmediate" as NSString)
}
