import PerfectHTTP

public typealias Middleware = (MiddlewareContext) -> ()

public class MiddlewareContext {

    public let request: HTTPRequest
    public let response: HTTPResponse
    public let middlewares: [Middleware]

    public fileprivate(set) var shared: [String: Any]

    public fileprivate(set) var current: Int

    public init(request: HTTPRequest, response: HTTPResponse, middlewares: [Middleware]) {
        self.request = request
        self.response = response
        self.shared = [String: Any]()
        self.middlewares = middlewares
        self.current = 0
    }

    public func next(err: Error? = nil) {
        guard err == nil else {
            return
        }
        if self.current < self.middlewares.count {
            let cur = self.current
            self.current = cur + 1
            self.middlewares[cur](self)
        }
    }

    deinit {
        print("deinit")
    }
}

open class MiddlewareHandler {

    private init() {}

    public static func all(_ middlewares: [Middleware]) -> RequestHandler {
        return { request, response in
            MiddlewareContext(request: request, response: response, middlewares: middlewares).next()
        }
    }
}

