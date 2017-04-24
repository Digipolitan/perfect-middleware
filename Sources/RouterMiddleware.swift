import PerfectHTTP
import PerfectHTTPServer

open class RouterMiddleware {

    public enum Event {
        case beforeAll
        case afterAll
    }

    private var beforeAll: [Middleware]
    private var afterAll: [Middleware]
    private var children: [String: RouterMiddleware]
    private var registry: RoutesRegistry
    private var errorHandler: ErrorHandler?

    public init() {
        self.beforeAll = [Middleware]()
        self.afterAll = [Middleware]()
        self.children = [String: RouterMiddleware]()
        self.registry = RoutesRegistry()
    }

    @discardableResult
    public func use(event: Event = .beforeAll, handler: @escaping MiddlewareHandler) -> Self {
        return self.use(event: event, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func use(event: Event = .beforeAll, middleware: Middleware) -> Self {
        switch event {
        case .beforeAll:
            self.beforeAll.append(middleware)
        case .afterAll:
            self.afterAll.append(middleware)
        }
        return self
    }

    @discardableResult
    public func use(errorHandler: @escaping ErrorHandler) -> Self {
        self.errorHandler = errorHandler
        return self
    }

    @discardableResult
    public func use(path: String, router: RouterMiddleware) -> Self {
        self.children[path] = router
        return self
    }

    @discardableResult
    public func get(path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.get(path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func get(path: String, middleware: Middleware) -> Self {
        self.registry.add(method: .get, path: path, middleware: middleware)
        return self
    }

    @discardableResult
    public func post(path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.post(path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func post(path: String, middleware: Middleware) -> Self {
        self.registry.add(method: .post, path: path, middleware: middleware)
        return self
    }

    @discardableResult
    public func put(path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.put(path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func put(path: String, middleware: Middleware) -> Self {
        self.registry.add(method: .put, path: path, middleware: middleware)
        return self
    }

    @discardableResult
    public func delete(path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.delete(path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func delete(path: String, middleware: Middleware) -> Self {
        self.registry.add(method: .delete, path: path, middleware: middleware)
        return self
    }

    @discardableResult
    public func options(path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.options(path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func options(path: String, middleware: Middleware) -> Self {
        self.registry.add(method: .options, path: path, middleware: middleware)
        return self
    }

    @discardableResult
    public func methods(_ methods: [HTTPMethod], path: String, handler: @escaping MiddlewareHandler) -> Self {
        return self.methods(methods, path: path, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func methods(_ methods: [HTTPMethod], path: String, middleware: Middleware) -> Self {
        methods.forEach { (method) in
            self.registry.add(method: method, path: path, middleware: middleware)
        }
        return self
    }

    fileprivate func getRoutes(path: String = "", beforeAll: [Middleware] = [], afterAll: [Middleware] = [], errorHandler: ErrorHandler? = nil) -> Routes {
        var routes = Routes(baseUri: path)

        let depthBeforeAll = beforeAll + self.beforeAll
        let depthAfterAll = afterAll + self.afterAll

        let curErrorHandler = (errorHandler != nil) ? errorHandler : self.errorHandler
        self.registry.routes.forEach { (method: HTTPMethod, value: [String : [Middleware]]) in
            value.forEach({ (key: String, value: [Middleware]) in
                let middlewares = depthBeforeAll + value + depthAfterAll
                routes.add(method: method, uri: key, handler: { request, response in
                    MiddlewareIterator(request: request, response: response, middlewares: middlewares, errorHandler: curErrorHandler).next()
                })
            })
        }

        let filePathComponents = path.filePathComponents
        self.children.forEach { (key: String, value: RouterMiddleware) in
            let childComponents = key.filePathComponents
            let components = filePathComponents + childComponents
            print(components.joined(separator: "/"))
            routes.add(value.getRoutes(path: components.joined(separator: "/"), beforeAll: depthBeforeAll, afterAll: depthAfterAll, errorHandler: curErrorHandler));
        }

        return routes
    }
}

public extension HTTPServer {

    public func use(router: RouterMiddleware) {
        self.addRoutes(router.getRoutes())
    }
}


fileprivate class RoutesRegistry {

    fileprivate private(set) var routes: [HTTPMethod: [String: [Middleware]]]

    public init() {
        self.routes = [HTTPMethod: [String: [Middleware]]]()
    }

    public func add(method: HTTPMethod, path: String, middleware: Middleware) {
        if self.routes[method] == nil {
            self.routes[method] = [String: [Middleware]]()
        }
        if self.routes[method]![path] == nil {
            self.routes[method]![path] = [Middleware]()
        }
        self.routes[method]![path]!.append(middleware)
    }
}
