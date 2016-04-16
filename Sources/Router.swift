//
//  Router.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    public func use(handler: (Request, Response, MiddlewareChain) -> ()){
        let middleware = BasicMiddleware(handler: handler)
        use(middleware)
    }
    
    public func use(handler: AsyncMiddleware){
        middlewares.append(handler)
    }
}

extension Slimane {
    public func get(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        get(path, handler: responder)
    }
    
    public func get(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .get, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func options(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        options(path, handler: responder)
    }
    
    public func options(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .options, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func post(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        post(path, handler: responder)
    }
    
    public func post(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .post, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func put(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        put(path, handler: responder)
    }
    
    public func put(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .put, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func patch(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        patch(path, handler: responder)
    }
    
    public func patch(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .patch, path: path, handler: handler)
        router.routes.append(route)
    }
}

extension Slimane {
    public func delete(path: String, handler: AsyncRespond){
        let responder = BasicAsyncResponder(handler)
        delete(path, handler: responder)
    }
    
    public func delete(path: String, handler: AsyncResponder){
        let route = BasicRouter(method: .delete, path: path, handler: handler)
        router.routes.append(route)
    }
}

