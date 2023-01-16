import JavaScriptCore

@objc public protocol ConsoleExports: JSExport {
    func log()
    func info()
    func warn()
}

@objc public class Console: NSObject, ConsoleExports {
    public func log() {
        let args = JSContext.currentArguments()!
        print(args.map { String("\($0)") }.joined(separator: " "))
    }

    public func info() {
        log()
    }

    public func warn() {
        log()
    }
}

public func initConsoleAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(Console(), forKeyedSubscript: "console" as NSString)
    rt.globalContext.setObject(Console.self, forKeyedSubscript: "Console" as NSString)
}
