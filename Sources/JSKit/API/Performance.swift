import JavaScriptCore
import QuartzCore

@objc protocol PerformanceExports: JSExport {
    func now() -> Double
}

@objc class Performance: NSObject, PerformanceExports {
    let startup = CACurrentMediaTime() * 1000.0

    func now() -> Double {
        return CACurrentMediaTime() * 1000.0 - startup
    }
}

public func initPerformanceAPI(_ rt: JSKitRuntime) {
    rt.globalContext.setObject(Performance(), forKeyedSubscript: "performance" as NSString)
}
