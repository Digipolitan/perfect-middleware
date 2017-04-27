//
//  RouterMiddleware.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 20/04/2017.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

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
    private var registry: RoutesRegistry
    private var errorHandler: ErrorHandler?
    private var verbose: Bool;

    public convenience init() {
        self.init(verbose: false)
    }

    public init(verbose: Bool) {
        self.beforeAll = [Middleware]()
        self.afterAll = [Middleware]()
        self.children = [String: RouterMiddleware]()
        self.registry = RoutesRegistry()
        self.verbose = verbose
    }

    @discardableResult
    public func use(event: Event, handler: @escaping MiddlewareHandler) -> Self {
        return self.use(event: event, middleware: MiddlewareWrapper(handler: handler))
    }

    @discardableResult
    public func use(event: Event, middleware: Middleware) -> Self {
        switch event {
        case .beforeAll:
            self.beforeAll.append(middleware)
        case .afterAll:
            self.afterAll.append(middleware)
        case .notFound:
            self.notFound = middleware
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
        self.children[RoutesRegistry.sanitize(path: path)] = router
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

    fileprivate func getRoutes(path: String = "", beforeAll: [Middleware] = [], afterAll: [Middleware] = [], verbose: Bool = false, errorHandler: ErrorHandler? = nil) -> Routes {
        var routes = Routes(baseUri: path)

        let depthBeforeAll = beforeAll + self.beforeAll
        let depthAfterAll = self.afterAll + afterAll

        let curErrorHandler = (self.errorHandler != nil) ? self.errorHandler : errorHandler
        let curVerbose = (verbose == true) ? verbose : self.verbose

        self.registry.routes.forEach { (method: HTTPMethod, value: [String : [Middleware]]) in
            value.forEach({ (key: String, value: [Middleware]) in
                let middlewares = depthBeforeAll + value + depthAfterAll
                if curVerbose {
                    Log.info(message: "HTTP Server listen \(method.description) on \(path)\(key)")
                }
                routes.add(method: method, uri: key, handler: { request, response in
                    MiddlewareIterator(request: request,
                                       response: response,
                                       middlewares: middlewares,
                                       errorHandler: curErrorHandler).next()
                })
            })
        }

        self.children.forEach { (key: String, value: RouterMiddleware) in
            routes.add(value.getRoutes(path: path + key,
                    beforeAll: depthBeforeAll,
                    afterAll: depthAfterAll,
                    verbose: curVerbose,
                    errorHandler: curErrorHandler
            ))
        }

        if let notFound = self.notFound {
            var notFoundMiddlewares = depthBeforeAll
            notFoundMiddlewares.append(notFound)
            notFoundMiddlewares.append(contentsOf: depthAfterAll)
            if curVerbose {
                Log.info(message: "HTTP Server listen 404 from" + (path == "" ? "/" : path));
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
        let sanitizePath = RoutesRegistry.sanitize(path: path)
        if self.routes[method] == nil {
            self.routes[method] = [String: [Middleware]]()
        }
        if self.routes[method]![sanitizePath] == nil {
            self.routes[method]![sanitizePath] = [Middleware]()
        }
        self.routes[method]![sanitizePath]!.append(middleware)
    }

    static fileprivate func sanitize(path: String) -> String {
        var characters = path.characters
        guard characters.count > 0 && path != "/" else {
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
}
