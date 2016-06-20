//
//  Router.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    public func use(_ handler: AsyncMiddlewareHandler){
        middlewares.append(BasicAsyncMiddleware(handler))
    }
    
    public func use(_ handler: AsyncMiddleware){
        middlewares.append(handler)
    }
}

extension Slimane {
    public func get(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        get(path, handler: responder)
    }
    
    public func get(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .get, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func options(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        options(path, handler: responder)
    }
    
    public func options(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .options, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func post(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        post(path, handler: responder)
    }
    
    public func post(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .post, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func put(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        put(path, handler: responder)
    }
    
    public func put(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .put, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func patch(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        patch(path, handler: responder)
    }
    
    public func patch(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .patch, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func delete(_ path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        delete(path, handler: responder)
    }
    
    public func delete(_ path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .delete, path: path, handler: handler)
        router.routes.append(route)
    }
}

