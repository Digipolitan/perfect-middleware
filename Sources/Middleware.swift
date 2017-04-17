//
//  Middleware.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 17/04/2017.
//
//

import PerfectHTTP

public typealias MiddlewareHandler = (RouteContext) throws -> ()

public protocol Middleware {

    func handle(context: RouteContext) throws

}
