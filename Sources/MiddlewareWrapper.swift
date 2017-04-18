//
//  MiddlewareWrapper.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 17/04/2017.
//
//

import PerfectHTTP

class MiddlewareWrapper: Middleware {

    private let handler: MiddlewareHandler

    public init(handler: @escaping MiddlewareHandler) {
        self.handler = handler
    }

    func handle(context: RouteContext) throws {
        try self.handler(context)
    }
}
