//
//  Router.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

public enum RoutingError: Error {
    case routeNotFound(path: String)
}

extension RoutingError: CustomStringConvertible {
    public var description: String {
        switch(self) {
        case .routeNotFound(let path):
            return "\(path) is not found"
        }
    }
}

extension Slimane {
    public func use(_ middleware: Middleware){
        self.middlewares.append(middleware)
    }
    
    public func use(_ handler: @escaping Respond){
        self.middlewares.append(BasicMiddleware(handler))
    }
    
    public func use(_ method: HTTPCore.Method, _ path: String, _ handler: @escaping Respond){
        self.router.routes.append(BasicRoute(method: method, path: path, handler: handler))
    }
    
    public func use(_ method: HTTPCore.Method, _ path: String, _ middlewares: [Middleware], _ handler: @escaping Respond){
        self.router.routes.append(BasicRoute(method: method, path: path, middlewares: middlewares, handler: handler))
    }
}

extension Slimane {
    public func `catch`(_ handler: @escaping (Error, Request, Response, (Chainer) -> Void) -> Void){
        self.catchHandler = handler
    }
    
    public func finally(_ handler: @escaping (Request, Response) -> Void){
        self.finallyHandler = handler
    }
}
