//
//  ServerType.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import SlimaneHTTP
import Suv

extension Slimane {
    public func listen(host host: String = "0.0.0.0", port: Int = 3000) throws {
        let server = SlimaneHTTP.createServer(Loop.defaultLoop) { [unowned self] result in
            if case .Error(let err) = result {
                return Logger.fatal(err)
            } else if case .Success(let req, let res) = result {
                self.dispatch(req, res)
            }
        }
        
        server.keepAliveTimeout = httpServerOption.keepAliveTimeout
        server.setNoDelay = httpServerOption.setNoDelay
        
        if Cluster.isMaster {
            try server.bind(Address(host: host, port: port))
        }
        
        try server.listen()
        
        Loop.defaultLoop.run()
    }
    
    private func beforeResponse(req: Request, _ res: Response){
        if showPowerdedBy {
            res.setHeader("X-Powerded-By", "Slimane")
        }
    
        // set callbacks
        res.beforeWrite {
            for fn in req.beforeWriteCallbacks {
                fn()
            }
        }
        
        res.afterWrite { response in
            for fn in req.afterWriteCallbacks {
                fn(response)
            }
        }
    }
    
    private func dispatch(req: Request, _ res: Response){
        beforeResponse(req, res)
        var middlewares: [SeriesCB]? = nil
        middlewares = self.middlewareStack.map { stack in
            return { next in
                do {
                    try stack.handler.handleRequest(req, res: res, next: next)
                } catch {
                    next(error)
                }
            }
        }
        
        // TODO Investigate memory leak possibility
        seriesTask(middlewares!) { [unowned self] err in
            middlewares = nil
            if let e = err {
                return self.errorHandler.handle(req: req, res: res, error: e)
            }
            
            // Dispatch route
            for stack in self.routerStack {
                if(stack.shouldHandle(req)) {
                    do {
                        return try stack.handler.handleRequest(req, res: res)
                    } catch let err {
                        self.errorHandler.handle(req: req, res: res, error: err)
                    }
                }
            }
            
            // 404 handler
            self.errorHandler.handle(req: req, res: res, error: Error.RouteNotFound(path: req.uri.path!))
        }
    }
}