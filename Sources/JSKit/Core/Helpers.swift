import JavaScriptCore

extension JSValue {
    func createError(_ message: String) -> JSValue {
        let error = JSValue(newErrorFromMessage: message, in: self.context)
        return error!
    }

    func with(rejection message: String) {
        let error = createError(message)
        self.call(withArguments: [error])
    }

    func with(resolved value: Any) {
        self.call(withArguments: [value])
    }

    func call() {
        self.call(withArguments: [])
    }
}
