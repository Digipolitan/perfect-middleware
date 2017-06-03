//
// Created by Benoit BRIATTE on 03/06/2017.
//

import Foundation

/**
 * Default implementation of the MiddlewareBinder
 * Allows the user to register middleware and handler inside an array
 */
internal class RouteMiddlewareBinder: MiddlewareBinder {

    public var middlewares: [Middleware]

    public init() {
        self.middlewares = []
    }

    @discardableResult
    public func bind(_ middleware: Middleware) -> Self {
        self.middlewares.append(middleware)
        return self
    }

    @discardableResult
    public func bind(_ middlewares: [Middleware]) -> Self {
        self.middlewares.append(contentsOf: middlewares)
        return self
    }

    @discardableResult
    public func bind(_ handler: @escaping MiddlewareHandler) -> Self {
        return self.bind(MiddlewareWrapper(handler: handler))
    }
}