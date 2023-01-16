import JavaScriptCore
import JavaScriptCoreExt

extension JSContext {
    public var runtime: JSKitRuntime {
        return self.objectForKeyedSubscript("__JSKitRuntime__")!.toObject()! as! JSKitRuntime
    }
}

public class JSKitRuntime: NSObject {
    public var virtualMachine: JSVirtualMachine
    public var moduleLoader: JSKitModuleLoader
    public var globalContext: JSContext
    public var eventLoop: JSKitEventLoop

    public override init() {
        virtualMachine = JSVirtualMachine()
        moduleLoader = JSKitModuleLoader()
        globalContext = JSContext(virtualMachine: virtualMachine)
        eventLoop = JSKitEventLoop()
        
        super.init()

        globalContext.moduleLoaderDelegate = moduleLoader

        globalContext.exceptionHandler = { context, exception in
            let error = exception!
            let message = error.toString()!
            let stack = error.objectForKeyedSubscript("stack").toString()!
            print("\(message)\n  at \(stack)")
        }

        globalContext.setObject(self, forKeyedSubscript: "__JSKitRuntime__" as NSString)
        
        initAPIs()
    }

    public func initAPIs() {
        initConsoleAPI(self)
        initTimersAPI(self)
        initPerformanceAPI(self)
    }

    public func evaluateScript(_ script: String, withSourceURL url: URL) -> JSValue {
        return globalContext.evaluateScript(script, withSourceURL: url)
    }

    public func evaluateModule(_ url: URL) throws -> JSValue {
        let script = try JSScript(
            of: .module,
            withSource: "",
            andSourceURL: url,
            andBytecodeCache: nil,
            in: virtualMachine
        )
        return globalContext.evaluateJSScript(script)
    }
}
