import JavaScriptCore

@objc public protocol ConsoleExports: JSExport {
    func log()
    func info()
    func warn()
    func error()
}

@objc public class Console: NSObject, ConsoleExports {
    func formatArguments(_ args: [Any]) -> String {
        return args.map { String("\($0)") }.joined(separator: " ")
    }

    public func log() {
        let context = JSContext.current()!
        let args = JSContext.currentArguments()!
        context.runtime.stdout(formatArguments(args))
    }

    public func info() {
        let context = JSContext.current()!
        let args = JSContext.currentArguments()!
        context.runtime.stdout(formatArguments(args))
    }

    public func warn() {
        let context = JSContext.current()!
        let args = JSContext.currentArguments()!
        context.runtime.stderr(formatArguments(args))
    }

    public func error() {
        let context = JSContext.current()!
        let args = JSContext.currentArguments()!
        context.runtime.stderr(formatArguments(args))
    }
}

public func initConsoleAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(Console(), forKeyedSubscript: "console" as NSString)
    rt.globalContext.setObject(Console.self, forKeyedSubscript: "Console" as NSString)
}
