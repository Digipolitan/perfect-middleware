import PerfectHTTP

/**
 * MiddlewareWrapper that wrap a middleware handler into a middleware subclass
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
internal class MiddlewareWrapper: Middleware {
    private let handler: MiddlewareHandler

    public init(handler: @escaping MiddlewareHandler) {
        self.handler = handler
    }

    public func handle(context: RouteContext) throws {
        try handler(context)
    }
}
