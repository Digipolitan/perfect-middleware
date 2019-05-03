//
// Created by Benoit BRIATTE on 03/06/2017.
//

/**
 * Composite MiddlewareBinder back an array of MiddlewareBinder
 * This class is used when the users want to bind the same middleware to 2 or more HTTPMethod in the same time
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
internal class CompositeMiddlewareBinder: MiddlewareBinder {
    public let children: [MiddlewareBinder]

    public init(children: [MiddlewareBinder]) {
        self.children = children
    }

    @discardableResult
    public func bind(_ middleware: Middleware) -> Self {
        children.forEach { child in
            child.bind(middleware)
        }
        return self
    }

    @discardableResult
    public func bind(_ middlewares: [Middleware]) -> Self {
        children.forEach { child in
            child.bind(middlewares)
        }
        return self
    }

    @discardableResult
    public func bind(_ handler: @escaping MiddlewareHandler) -> Self {
        return bind(MiddlewareWrapper(handler: handler))
    }
}
