import PerfectHTTP

open class RouterMiddleware {

    public enum Event {
        case beforeAll
        case afterAll
    }

    public static let `default` = RouterMiddleware()

    private var beforeAll: [Middleware]
    private var afterAll: [Middleware]
    private var errorHandler: ErrorHandler?

    public init() {
        self.beforeAll = [Middleware]()
        self.afterAll = [Middleware]()
    }

    public func use(event: Event = .beforeAll, middlewareHandler: @escaping MiddlewareHandler) -> Self {
        return self.use(event: event, middleware: MiddlewareWrapper(handler: middlewareHandler))
    }

    public func use(event: Event = .beforeAll, middleware: Middleware) -> Self {
        switch event {
        case .beforeAll:
            self.beforeAll.append(middleware)
        case .afterAll:
            self.afterAll.append(middleware)
        }
        return self
    }

    public func use(errorHandler: @escaping ErrorHandler) -> Self {
        self.errorHandler = errorHandler
        return self
    }

    public func builder() -> RequestHandlerBuilder {
        return RequestHandlerBuilder(beforeAll: self.beforeAll, afterAll: self.afterAll, errorHandler: self.errorHandler)
    }
}
