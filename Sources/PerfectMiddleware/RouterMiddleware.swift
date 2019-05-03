import PerfectHTTP
import PerfectHTTPServer
import PerfectLib

/**
 * The middleware router for the routing of requests
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
open class RouterMiddleware {
    /**
     * Events for middleware
     */
    public enum Event {
        /** Call the middleware before all others */
        case beforeAll
        /** Call the middleware after all others */
        case afterAll
        /** Call the middleware if no routes were found */
        case notFound
    }

    private var beforeAll: [Middleware]
    private var afterAll: [Middleware]
    private var notFound: Middleware?
    private var children: [String: RouterMiddleware]
    private var registry: RouteMiddlewareRegistry
    private var errorHandler: ErrorHandler?
    private var verbose: Bool

    public static func sanitize(path: String) -> String {
        var characters = path
        guard characters.count > 0, path != "/" else {
            return "/"
        }
        let last = characters.endIndex
        let separator = Character(UnicodeScalar(47))
        if characters[characters.index(before: last)] == separator {
            characters.removeLast()
        }
        let first = characters.startIndex
        if characters[first] != separator {
            characters.insert(separator, at: first)
        }
        return String(characters)
    }

    public convenience init() {
        self.init(verbose: false)
    }

    public init(verbose: Bool) {
        beforeAll = [Middleware]()
        afterAll = [Middleware]()
        children = [String: RouterMiddleware]()
        registry = RouteMiddlewareRegistry()
        self.verbose = verbose
    }

    @discardableResult
    public func use(event: Event, handler: @escaping MiddlewareHandler) -> Self {
        return use(event: event, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func use(event: Event, middleware: Middleware) -> Self {
        switch event {
        case .beforeAll:
            beforeAll.append(middleware)
        case .afterAll:
            afterAll.append(middleware)
        case .notFound:
            notFound = middleware
        }
        return self
    }

    @discardableResult
    public func use(errorHandler: @escaping ErrorHandler) -> Self {
        self.errorHandler = errorHandler
        return self
    }

    @discardableResult
    public func use(path: String, child router: RouterMiddleware) -> Self {
        children[RouterMiddleware.sanitize(path: path)] = router
        return self
    }

    public func get(path: String) -> MiddlewareBinder {
        return binder(method: .get, path: path)
    }

    public func post(path: String) -> MiddlewareBinder {
        return binder(method: .post, path: path)
    }

    public func put(path: String) -> MiddlewareBinder {
        return binder(method: .put, path: path)
    }

    public func delete(path: String) -> MiddlewareBinder {
        return binder(method: .delete, path: path)
    }

    public func options(path: String) -> MiddlewareBinder {
        return binder(method: .options, path: path)
    }

    public func methods(_ methods: [HTTPMethod], path: String) -> MiddlewareBinder {
        return CompositeMiddlewareBinder(children: methods.map { method -> MiddlewareBinder in
            self.binder(method: method, path: path)
        })
    }

    public func binder(method: HTTPMethod, path: String) -> MiddlewareBinder {
        return registry.findOrCreate(method: method, path: path)
    }

    fileprivate func getRoutes(path: String = "", beforeAll: [Middleware] = [], afterAll: [Middleware] = [], verbose: Bool = false, errorHandler: ErrorHandler? = nil) -> Routes {
        var routes = Routes(baseUri: path)

        let depthBeforeAll = beforeAll + self.beforeAll
        let depthAfterAll = self.afterAll + afterAll

        let curErrorHandler = (self.errorHandler != nil) ? self.errorHandler : errorHandler
        let curVerbose = (verbose == true) ? verbose : self.verbose

        registry.binders.forEach { method, value in
            value.forEach { key, value in
                let middlewares = depthBeforeAll + value.middlewares + depthAfterAll
                if curVerbose {
                    Log.info(message: "HTTP Server listen \(method.description) on \(path)\(key)")
                }
                routes.add(method: method, uri: key, handler: { request, response in
                    MiddlewareIterator(request: request,
                                       response: response,
                                       middlewares: middlewares,
                                       errorHandler: curErrorHandler).next()
                })
            }
        }

        children.forEach { key, value in
            routes.add(value.getRoutes(path: path + key,
                                       beforeAll: depthBeforeAll,
                                       afterAll: depthAfterAll,
                                       verbose: curVerbose,
                                       errorHandler: curErrorHandler))
        }

        if let notFound = self.notFound {
            var notFoundMiddlewares = depthBeforeAll
            notFoundMiddlewares.append(notFound)
            notFoundMiddlewares.append(contentsOf: depthAfterAll)
            if curVerbose {
                Log.info(message: "HTTP Server listen 404 from " + (path == "" ? "/" : path))
            }
            routes.add(uri: "**", handler: { request, response in
                MiddlewareIterator(request: request,
                                   response: response,
                                   middlewares: notFoundMiddlewares,
                                   errorHandler: curErrorHandler).next()
            })
        }

        return routes
    }
}

/**
 * Add RouterMiddleware supports for HTTPServer
 */
public extension HTTPServer {
    /**
     * Register the router inside the HttpServer by adding all routes
     * @param router The router midddleware to register
     */
    func use(router: RouterMiddleware) {
        addRoutes(router.getRoutes())
    }
}
