//
//  Slimane+Router.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

// router
extension Slimane {
    public func use(handler: MiddlewareType) {
        let stack = MiddlewareStack(handler: handler)
        self.middlewareStack.append(stack)
    }
    
    public func use(handler: Middleware) {
        let stack = MiddlewareStack(functionHandler: handler)
        self.middlewareStack.append(stack)
    }

    public func use(path: String, handler: RouteType) {
        let stack = RouteStack(path: nil, handler: handler)
        self.routerStack.append(stack)
    }
    
    public func use(path: String, handler: Route) {
        let stack = RouteStack(path: nil, functionHandler: handler)
        self.routerStack.append(stack)
    }
    
    public func get(path: String, _ action: Route) {
        self.routerStack.append(RouteStack(path: path, method: .GET, functionHandler: action))
    }

    public func get(path: String, _ action: RouteType) {
        self.routerStack.append(RouteStack(path: path, method: .GET, handler: action))
    }

    public func post(path: String, _ action: RouteType) {
        self.routerStack.append(RouteStack(path: path, method: .POST, handler: action))
    }
    
    public func post(path: String, _ action: Route) {
        self.routerStack.append(RouteStack(path: path, method: .POST, functionHandler: action))
    }

    public func put(path: String, _ action: RouteType) {
        self.routerStack.append(RouteStack(path: path, method: .PUT, handler: action))
    }
    
    public func put(path: String, _ action: Route) {
        self.routerStack.append(RouteStack(path: path, method: .PUT, functionHandler: action))
    }

    public func patch(path: String, _ action: RouteType) {
        self.routerStack.append(RouteStack(path: path, method: .PATCH, handler: action))
    }
    
    public func patch(path: String, _ action: Route) {
        self.routerStack.append(RouteStack(path: path, method: .PATCH, functionHandler: action))
    }

    public func delete(path: String, _ action: RouteType) {
        self.routerStack.append(RouteStack(path: path, method: .DELETE, handler: action))
    }
    
    public func delete(path: String, _ action: Route) {
        self.routerStack.append(RouteStack(path: path, method: .DELETE, functionHandler: action))
    }
}
