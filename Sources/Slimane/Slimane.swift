//
//  Slimane.swift
//  Slimane
//
//  Created by Yuki Takei on 4/12/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import Skelton

public class Slimane {
    internal var middlewares: [Middleware] = []

    internal var router = Router()

    public var setNodelay = false

    public var keepAliveTimeout: UInt = 15

    public var backlog: UInt = 1024
    
    var catchHandler: (Error, Request, Response, (Chainer) -> Void) -> Void = { _ in }
    
    var finallyHandler: (Request, Response) -> Void = { _ in }

    public init(){}
}
