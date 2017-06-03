import PerfectHTTP

/**
 * MiddlewareBinder protocol, is used to bind middlewares or handlers inside a route with a method chaining pattern
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
public protocol MiddlewareBinder {

    /**
     * Register a middleware
     * @param middleware The middleware
     * @return MiddlewareBinder
     */
    @discardableResult
    func bind(_ middleware: Middleware) -> Self

    /**
     * Register an array of middleware
     * @param middlewares The array
     * @return MiddlewareBinder
     */
    @discardableResult
    func bind(_ middlewares: [Middleware]) -> Self

    /**
     * Register a closure
     * @param handler The handler
     * @return MiddlewareBinder
     */
    @discardableResult
    func bind(_ handler: @escaping MiddlewareHandler) -> Self
}