import Foundation
import JavaScriptCore
import JavaScriptCoreExt

public protocol JSKitModuleLoaderDelegate {
    func moduleShouldHandled(name: String) -> Bool
    func moduleWillImport(name: String, completion: @escaping (Result<Any, Error>) -> Void) -> Void
    func moduleWillImport(name: String) async throws -> Any
    func moduleDidImport(name: String, module: Any) -> Void
}

public extension JSKitModuleLoaderDelegate {
    func moduleShouldHandled(name: String) -> Bool {
        return false
    }
    
    func moduleWillImport(name: String, completion: @escaping (Result<Any, Error>) -> Void) -> Void {
        Task {
            do {
                let script = try await moduleWillImport(name: name)
                completion(.success(script))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func moduleWillImport(name: String) async throws -> Any {
        throw JSKitError.message("moduleShouldHandled returned true but moduleWillImport is not implemented")
    }
    
    func moduleDidImport(name: String, module: Any) -> Void {
        return
    }
}

public class JSKitModuleLoader: NSObject, JSModuleLoaderDelegate {
    var delegate: JSKitModuleLoaderDelegate?
    
    public func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!) {
        guard let identifier = identifier else {
            reject.with(rejection: "Identifier is nil")
            return
        }

        guard let filePath = identifier.toString() else {
            reject.with(rejection: "Identifier is not a string")
            return
        }
        
        context.runtime.eventLoop.perform { [weak self] completion in
            if let delegate = self?.delegate, delegate.moduleShouldHandled(name: filePath) {
                delegate.moduleWillImport(name: filePath) { result in
                    switch result {
                    case .success(let success):
                        resolve.with(resolved: success)
                        delegate.moduleDidImport(name: filePath, module: success)
                    case .failure(let failure):
                        reject.with(rejection: failure.localizedDescription)
                    }
                    completion()
                }
                return
            }

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

            let script: Any
            do {
                script = try JSCExtScript(
                    of: .module,
                    withSource: source,
                    andSourceURL: file,
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
