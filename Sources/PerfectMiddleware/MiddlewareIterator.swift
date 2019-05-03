import PerfectHTTP

/**
 * Internal RouteContext implementation
 * This implementation iterate over all middlewares one by one
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
internal class MiddlewareIterator: RouteContext {
    public let request: HTTPRequest
    public let response: HTTPResponse

    private let middlewares: [Middleware]
    private let errorHandler: ErrorHandler?
    private var userInfo: [String: Any]
    private var current: Int

    public init(request: HTTPRequest, response: HTTPResponse, middlewares: [Middleware], errorHandler: ErrorHandler?) {
        self.request = request
        self.response = response
        self.middlewares = middlewares
        self.errorHandler = errorHandler
        userInfo = [String: Any]()
        current = 0
    }

    public func next() {
        if current < middlewares.count {
            let cur = current
            current = cur + 1
            do {
                try middlewares[cur].handle(context: self)
            } catch {
                current = middlewares.count
                if errorHandler != nil {
                    errorHandler!(error, self)
                }
            }
        }
    }

    public subscript(key: String) -> Any? {
        get {
            return userInfo[key]
        }
        set {
            userInfo[key] = newValue
        }
    }
}
