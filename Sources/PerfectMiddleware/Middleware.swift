import PerfectHTTP

/**
 * Middleware handler that must be register in a RouterMiddleware
 * This closure handle the request, middleware handler are chainable with the RouterMiddleware
 */
public typealias MiddlewareHandler = (RouteContext) throws -> Void

/**
 * Special handler that must be register in a RouterMiddleware
 * This closure handler errors that should be raised by a middleware
 */
public typealias ErrorHandler = (Error, RouteContext) -> Void

/**
 * Middleware protocol, must be register in a RouterMiddleware
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
public protocol Middleware {
    /**
     * Handle the current route
     * @param context The route context which contains all informations about the request
     * @throws Error
     */
    func handle(context: RouteContext) throws
}
