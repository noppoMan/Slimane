//
//  Slimane.swift
//  Slimane
//
//  Created by Yuki Takei on 4/12/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import Time
@_exported import Skelton
@_exported import S4
@_exported import C7
@_exported import AsyncResponderConvertible
@_exported import AsyncHTTPSerializer
@_exported import HTTPUpgradeAsync

public class Slimane {
    internal var middlewares: [AsyncMiddleware] = []

    internal var router: Router
    
    internal var server: Skelton? = nil

    public var setNodelay = false

    public var keepAliveTimeout: UInt = 15

    public var backlog: UInt = 1024

    public var errorHandler: (Error) -> Response = defaultErrorHandler

    public init(){
        self.router = Router { _, result in
            result { Response() }
        }
    }
}

func defaultErrorHandler(_ error: Error) -> Response {
    let response: Response
    switch error {
    case RoutingError.routeNotFound:
        response = Response(status: .notFound, body: "\(error)")
    case StaticMiddlewareError.resourceNotFound:
        response = Response(status: .notFound, body: "\(error)")
    default:
        response = Response(status: .internalServerError, body: "\(error)")
    }
    return response
}
