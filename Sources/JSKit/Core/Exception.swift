import JavaScriptCore

public class JSException: Error {
    public let jsValue: JSValue
    public let name: String
    public let message: String
    public let rawStack: String
    public let cause: JSException?
    public let stack: [String]

    public init(_ jsValue: JSValue) {
        self.jsValue = jsValue
        self.name = jsValue.objectForKeyedSubscript("name").toString() ?? "Error"
        self.message = jsValue.objectForKeyedSubscript("message").toString() ?? ""
        self.rawStack = jsValue.objectForKeyedSubscript("stack").toString() ?? ""
        let causeEx = jsValue.objectForKeyedSubscript("cause").toObject() as? JSValue
        if let causeEx = causeEx {
            self.cause = JSException(causeEx)
        } else {
            self.cause = nil
        }
        self.stack = rawStack
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    public var description: String {
        var desc = "\(name): \(message)"

        if !stack.isEmpty {
            desc += "\n\(stack.map { "  at " + $0 }.joined(separator: "\n"))"
        }

        if let cause = cause {
            desc += "\nCaused by: \(cause)"
        }

        return desc
    }
}
