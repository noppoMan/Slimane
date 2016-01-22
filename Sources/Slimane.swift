//
//  Slimane.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import SlimaneHTTP

public typealias Request = HTTPRequest
public typealias Response = HTTPResponse

public typealias Middleware = (Request, Response, MiddlewareChain) throws -> Void
public typealias Route = (Request, Response) throws -> Void

public struct HTTPServerOption {
    public var keepAliveTimeout: UInt = 0
    public var setNoDelay = false
}

public class Slimane {
    // Aliases
    public var showPowerdedBy = true
    
    public let httpServerOption = HTTPServerOption()
    
    public var context: [String: Any] = [:]
    
    // Stacks
    var middlewareStack = [MiddlewareStack]()
    var routerStack = [RouteStack]()
    
    
    // Error Handler
    public var errorHandler: ErrorHandler = DefaultErrorHandler()
    
    public init(){}
}

public struct DefaultErrorHandler: ErrorHandler {
    public func handle(req req: Request, res: Response, error: ErrorType) {
        Logger.fatal(error)
        switch(error) {
        case Error.RouteNotFound(let path):
            res.status(.NotFound).write("\(path) is not found.")
        default:
            res.status(.BadRequest).write("\(error)")
        }
    }
}