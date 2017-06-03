import PerfectHTTP

/**
 * Registry of RouteMiddlewareBinder, back all the route binding of the RouterMiddleware
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
internal class RouteMiddlewareRegistry {

    public private(set) var binders: [HTTPMethod: [String: RouteMiddlewareBinder]]

    public init() {
        self.binders = [HTTPMethod: [String: RouteMiddlewareBinder]]()
    }

    /**
     * Find or create a RouteMiddlewareBinder
     * @param method The HTTPMethod
     * @param path The route path
     * @return Old RouteMiddlewareBinder with the combination of HTTPMethod / path otherwise a new one
     */
    public func findOrCreate(method: HTTPMethod, path: String) -> RouteMiddlewareBinder {
        let sanitizePath = RouterMiddleware.sanitize(path: path)
        if self.binders[method] == nil {
            self.binders[method] = [String: RouteMiddlewareBinder]()
        }
        if let binder = self.binders[method]![sanitizePath] {
            return binder
        }
        let binder = RouteMiddlewareBinder()
        self.binders[method]![sanitizePath] = binder
        return binder
    }
}