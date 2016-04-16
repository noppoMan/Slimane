//
//  AsyncRouter.swift
//  SlimaneMiddleware
//
//  Created by Yuki Takei on 4/13/16.
//
//

public protocol AsyncRouter: AsyncResponder {
    var routes: [AsyncRoute] { get }
    var fallback: AsyncResponder { get }
    func match(request: Request) -> AsyncRoute?
}

public struct Router: AsyncRouter {
    let respond: AsyncRespond
    
    public var routes: [AsyncRoute] = []
    
    public var fallback: AsyncResponder = BasicAsyncResponder { _, result in
        result {
            Response(status: .methodNotAllowed)
        }
    }
    
    public init(_ respond: AsyncRespond) {
        self.respond = respond
    }
    
    public func respond(to request: Request, result: (Void throws -> Response) -> Void) {
        return self.respond(to: request, result: result)
    }
    
    public func match(request: Request) -> AsyncRoute? {
        guard let path = request.path else {
            return nil
        }
        
        let request = request
        for responder in routes {
            if responder.regexp.matches(path) && request.method == responder.method {
                return responder
            }
        }
        return nil
    }
}