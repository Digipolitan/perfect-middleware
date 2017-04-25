//
//  MiddlewareWrapper.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 17/04/2017.
//
//

import PerfectHTTP

/**
 * MiddlewareWrapper that wrap a middleware handler into a middleware subclass
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
class MiddlewareWrapper: Middleware {

    private let handler: MiddlewareHandler

    public init(handler: @escaping MiddlewareHandler) {
        self.handler = handler
    }

    public func handle(context: RouteContext) throws {
        try self.handler(context)
    }
}
