//
//  MiddleWareStack.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import SlimaneMiddleware

private struct FunctionHandlerWrapper: MiddlewareType {
    var handler: (Request, Response, MiddlewareChain) throws -> ()
    
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws {
        try handler(req, res, next)
    }
}

struct MiddlewareStack {
    let handler: MiddlewareType
    
    init(handler: MiddlewareType) {
        self.handler = handler
    }
    
    init(functionHandler: Middleware) {
        self.handler = FunctionHandlerWrapper(handler: functionHandler)
    }
}