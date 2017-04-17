import PerfectHTTP

public typealias ErrorHandler = (Error, RouteContext) -> ()

open class MiddlewareIterator: RouteContext {

    public let request: HTTPRequest
    public let response: HTTPResponse

    private let middlewares: [Middleware]
    private let errorHandler: ErrorHandler?
    private var userInfo: [String: Any]
    private var current: Int

    public init(request: HTTPRequest, response: HTTPResponse, middlewares: [Middleware], errorHandler: ErrorHandler? = nil) {
        self.request = request
        self.response = response
        self.middlewares = middlewares
        self.errorHandler = errorHandler
        self.userInfo = [String: Any]()
        self.current = 0
    }

    public func next() {
        if self.current < self.middlewares.count {
            let cur = self.current
            self.current = cur + 1
            do {
                try self.middlewares[cur].handle(context: self)
            } catch {
                self.current = self.middlewares.count
                if self.errorHandler != nil {
                    self.errorHandler!(error, self)
                }
            }
        }
    }

    public subscript(key: String) -> Any? {
        get {
            return self.userInfo[key]
        }
        set {
            self.userInfo[key] = newValue
        }
    }
}
