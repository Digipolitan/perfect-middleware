//
//  RequestHandlerBuilder.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 17/04/2017.
//
//

import PerfectHTTP

public class RequestHandlerBuilder {

    public fileprivate(set) var middlewares: [Middleware];
    public let errorHandler: ErrorHandler?
    private let afterAll: [Middleware]?

    public init(beforeAll: [Middleware]? = nil, afterAll: [Middleware]? = nil, errorHandler: ErrorHandler? = nil) {
        self.middlewares = beforeAll != nil ? beforeAll! : [Middleware]()
        self.afterAll = afterAll
        self.errorHandler = errorHandler
    }

    @discardableResult
    public func append(middleware: Middleware) -> Self {
        self.middlewares.append(middleware)
        return self
    }

    @discardableResult
    public func append(handler: @escaping MiddlewareHandler) -> Self {
        return self.append(middleware: MiddlewareWrapper(handler: handler))
    }

    public func build() -> RequestHandler {
        var middlewares = self.middlewares
        if self.afterAll != nil {
            middlewares.append(contentsOf: self.afterAll!)
        }
        let errorHandler = self.errorHandler
        return { request, response in
            MiddlewareIterator(request: request, response: response, middlewares: middlewares, errorHandler: errorHandler).next()
        }
    }
}
