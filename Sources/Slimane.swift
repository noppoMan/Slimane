//
//  Slimane.swift
//  Slimane
//
//  Created by Yuki Takei on 4/12/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

@_exported import Time
@_exported import Middleware
@_exported import Skelton
@_exported import S4
@_exported import C7

public class Slimane {
    internal var middlewares: [AsyncMiddleware] = []

    internal var router: Router
    
    public var setNodelay = false
    
    public var keepAliveTimeout: UInt = 15
    
    public var backlog: UInt = 1024
    
    public var errorHandler: ErrorProtocol -> Response = defaultErrorHandler
    
    public init(){
        self.router = Router { _, result in
            result { Response() }
        }
    }

    internal func dispatch(request: Request, stream: Skelton.HTTPStream){
        var request = request
        let responder: AsyncResponder
        if let route = self.router.match(request) {
            request.params = route.params(request)
            responder = BasicAsyncResponder { request, result in
                if request.isIntercepted {
                    result {
                        request.response
                    }
                    return
                }
                route.handler.respond(to: request, result: result)
            }
        } else {
            responder = BasicAsyncResponder { [unowned self] _, result in
                self.handleError(Error.RouteNotFound(path: request.uri.path ?? "/"), request, stream)
            }
        }
        
        self.middlewares.chain(to: responder).respond(to: request) { [unowned self] in
            do {
                let response = try $0()
                self.processStream(response, request, stream)
            } catch {
                self.handleError(error, request, stream)
            }
        }
    }

    private func processStream(response: Response, _ request: Request, _ stream: Skelton.HTTPStream){
        var response = response
        
        if response.contentLength == 0 && !response.isChunkEncoded {
            response.contentLength = response.bodyLength
        }
        
        stream.send(response.responseData)
        closeStream(request, stream)
    }
    
    private func handleError(error: ErrorProtocol, _ request: Request, _ stream: Skelton.HTTPStream){
        let response = errorHandler(error)
        processStream(response, request, stream)
    }
}

private func closeStream(request: Request, _ stream: Skelton.HTTPStream){
    if request.isKeepAlive {
        stream.unref()
    } else {
        stream.close()
    }
}

func defaultErrorHandler(error: ErrorProtocol) -> Response {
    let response: Response
    switch error {
    case Error.RouteNotFound:
        response = Response(status: .notFound, body: "\(error)")
    case Error.ResourceNotFound:
        response = Response(status: .notFound, body: "\(error)")
    default:
        response = Response(status: .badRequest, body: "\(error)")
    }
    return response
}