import JavaScriptCore
import JavaScriptCoreExt

let JSKitRuntimeKey = "__JSKitRuntime__"

extension JSContext {
    public var runtime: JSKitRuntime {
        return self.objectForKeyedSubscript(JSKitRuntimeKey)!.toObject()! as! JSKitRuntime
    }
}

enum JSKitError: Error {
    case message(String)
}

@objc protocol JSKitRuntimeExports: JSExport {
    func resolveModuleExports(_ exports: JSValue)
    func rejectModuleExports(_ error: JSValue)
}

@objc public class JSKitRuntime: NSObject, JSKitRuntimeExports {
    public var virtualMachine: JSVirtualMachine
    public var moduleLoader: JSKitModuleLoader
    public var globalContext: JSContext
    public var eventLoop: JSKitEventLoop

    public var exceptionHandler: (JSException) -> Void = { print($0.description) }
    
    public var stdout: (String) -> Void = { print($0) }
    public var stderr: (String) -> Void = { print($0) }
    
    public var alert: (String) -> Void = { print($0) }
    public var confirm: (String) -> Bool = { _ in false }
    public var prompt: (String, String?) -> String? = { $1 }

    public static var current: JSKitRuntime {
        return JSContext.current()!.runtime
    }

    public override init() {
        virtualMachine = JSVirtualMachine()
        moduleLoader = JSKitModuleLoader()
        globalContext = JSContext(virtualMachine: virtualMachine)
        eventLoop = JSKitEventLoop()
        
        super.init()

        globalContext.moduleLoaderDelegate = moduleLoader

        globalContext.exceptionHandler = { context, exception in
            if let exception = exception {
                self.exceptionHandler(JSException(exception))
            }
        }

        globalContext.setObject(self, forKeyedSubscript: JSKitRuntimeKey as NSString)
        
        initAPIs()
    }

    public func initAPIs() {
        initConsoleAPI(self)
        initAlertsAPI(self)
        initTimersAPI(self)
        initPerformanceAPI(self)
    }

    public func evaluateScript(_ script: String, withSourceURL url: URL) -> JSValue {
        return globalContext.evaluateScript(script, withSourceURL: url)
    }

    var moduleEvaluateCallback: ((JSValue?, JSValue?) -> Void)?

    public func resolveModuleExports(_ exports: JSValue) {
        if let callback = moduleEvaluateCallback {
            moduleEvaluateCallback = nil
            callback(exports, nil)
        }
    }

    public func rejectModuleExports(_ error: JSValue) {
        if let callback = moduleEvaluateCallback {
            moduleEvaluateCallback = nil
            exceptionHandler(JSException(error))
            callback(nil, error)
        }
    }

    public func evaluateModule(
        _ url: URL,
        _ completion: @escaping (JSValue?, JSValue?) -> Void
    ) throws {
        if moduleEvaluateCallback != nil {
            throw JSKitError.message("Module evaluation is already in progress")
        }
        moduleEvaluateCallback = completion
        globalContext.evaluateScript(
            """
            const module = import(`\(url.absoluteString)`);
            module.then(
                (exports) => {
                    \(JSKitRuntimeKey).resolveModuleExports(exports);
                },
                (error) => {
                    \(JSKitRuntimeKey).rejectModuleExports(error);
                },
            );
            """,
            withSourceURL: URL(string: "jskit:internal/module")
        )
    }
}
