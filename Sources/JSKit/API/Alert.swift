import JavaScriptCore

let alert: @convention(block) (String) -> Void = { message in
    JSKitRuntime.current.alert(message)
}

let prompt: @convention(block) (String, String?) -> String? = { message, defaultText in
    return JSKitRuntime.current.prompt(message, defaultText)
}

let confirm: @convention(block) (String) -> Bool = { message in
    return JSKitRuntime.current.confirm(message)
}

public func initAlertsAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(alert, forKeyedSubscript: "alert" as NSString)
    rt.globalContext.setObject(prompt, forKeyedSubscript: "prompt" as NSString)
    rt.globalContext.setObject(confirm, forKeyedSubscript: "confirm" as NSString)
}
