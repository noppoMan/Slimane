//
//  AsyncMiddlewareWrapper.swift
//  Slimane
//
//  Created by Yuki Takei on 4/18/16.
//
//


internal struct AsyncMiddlewareWrapper: AsyncMiddleware {
    let handler: AsyncMiddleware
    
    init(handler: AsyncMiddleware){
        self.handler = handler
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder, result: (Void throws -> Response) -> Void) {
        // Intercept response
        if request.response.isIntercepted {
            result {
                request.response
            }
            return
        }
        handler.respond(to: request, chainingTo: next, result: result)
    }
}
