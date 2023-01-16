import Foundation
import JavaScriptCoreExt

public class JSKitModuleLoader: NSObject, JSModuleLoaderDelegate {
    public func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!) {
        guard let identifier = identifier else {
            reject.with(rejection: "Identifier is nil")
            return
        }

        guard let filePath = identifier.toString() else {
            reject.with(rejection: "Identifier is not a string")
            return
        }
        
        context.runtime.eventLoop.perform { completion in
            guard let file = URL(string: filePath) else {
                reject.with(rejection: "Identifier is not a string")
                return completion()
            }

            guard FileManager.default.fileExists(atPath: file.path) else {
                reject.with(rejection: "File does not exist: \(file)")
                return completion()
            }

            let source: String
            do {
                source = try String(contentsOfFile: file.path, encoding: .utf8)
            } catch {
                reject.with(rejection: "Could not read file: \(error)")
                return completion()
            }

            let script: JSScript
            do {
                script = try JSScript(
                    of: .module,
                    withSource: source,
                    andSourceURL: file,
                    andBytecodeCache: nil,
                    in: context.virtualMachine
                )
            } catch {
                reject.with(rejection: "Could not create script: \(error)")
                return completion()
            }

            resolve.with(resolved: script)
            completion()
        }
    }
}
