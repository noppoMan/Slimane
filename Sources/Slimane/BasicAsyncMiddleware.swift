//
//  BasicAsyncMiddleware.swift
//  Slimane
//
//  Created by Yuki Takei on 4/18/16.
//
//

public typealias AsyncMiddlewareHandler = (_ to: Request, _ next: AsyncResponder, _ result: @escaping ((Void) throws -> Response) -> Void) -> Void

public struct BasicAsyncMiddleware: AsyncMiddleware {
    let handler: AsyncMiddlewareHandler
    
    public init(_ handler: AsyncMiddlewareHandler){
        self.handler = handler
    }
    
    public func respond(to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void) {
        handler(request, next, result)
    }
}
