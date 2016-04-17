//
//  Slimane.swift
//  Slimane
//
//  Created by Yuki Takei on 4/12/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

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
        request.response = Response(status: .ok, headers: ["data": Header(Time.rfc1123), "server": Header("Slimane")])
        
        self.middlewares.chain(to: BasicAsyncResponder { _, result in
            result {
                return request.response
            }
        })
        .respond(to: request, result: { [unowned self] in
            do {
                let response = try $0()
                if response.isIntercepted {
                    self.processStream(response, request, stream)
                } else {
                    if let route = self.router.match(request) {
                        request.params = route.params(request)
                        route.handler.respond(to: request) {
                            do {
                                let _response = try $0()
                                self.processStream(response.merged(_response), request, stream)
                            } catch {
                                self.handlerError(error, request, stream)
                            }
                        }
                    } else {
                        self.handlerError(Error.RouteNotFound(path: request.uri.path ?? "/"), request, stream)
                    }
                }
            } catch {
                self.handlerError(error, request, stream)
            }
        })
    }

    private func processStream(response: Response, _ request: Request, _ stream: Skelton.HTTPStream){
        var response = response
        
        if response.contentLength == 0 && !response.isChunkEncoded {
            response.contentLength = response.bodyLength
        }
        
        stream.send(response.responseData)
        closeStream(request, stream)
    }
    
    private func handlerError(error: ErrorProtocol, _ request: Request, _ stream: Skelton.HTTPStream){
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