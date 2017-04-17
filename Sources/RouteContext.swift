//
//  RouteContext.swift
//  DGPerfectMiddleware
//
//  Created by Benoit BRIATTE on 17/04/2017.
//
//

import PerfectHTTP

public protocol RouteContext: class {

    var request: HTTPRequest { get }
    var response: HTTPResponse { get }

    func next()

    subscript(key: String) -> Any? { get set }
}
