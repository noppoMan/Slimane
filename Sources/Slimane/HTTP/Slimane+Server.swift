//
//  Serve.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    
    public func listen(host: String = "0.0.0.0", port: Int = 3000) throws {
        let server = Skelton { [unowned self] result in
            switch result {
            case .onRequest(let request, let stream):
                self.dispatch(request, stream)
            case .onError(let error):
                print(error)
            default:
                break //ignore eof
            }
        }
        
        // proxy settings
        server.setNoDelay = self.setNodelay
        server.keepAliveTimeout = self.keepAliveTimeout
        server.backlog = self.backlog
        
        // bind & listen
        if Cluster.isMaster {
            try server.bind(host: host, port: port)
        }
        try server.listen()
    }
    
    private func dispatch(_ request: Request, _ stream: DuplexStream){
        middlewares.chain(request: request, response: Response()) { [unowned self] chainer in
            switch chainer {
            case .respond(let response):
                self.respond(request, response, stream)
                
            case .next(let request, let response):
                if let (route, request) = self.router.matchedRoute(for: request) {
                    route.middlewares.chain(request: request, response: response) { [unowned self] chainer in
                        switch chainer {
                        case .respond(let response):
                            self.respond(request, response, stream)
                            
                        case .next(let request, let response):
                            route.respond(request, response) { chainer in
                                switch chainer {
                                case .respond(let response):
                                    self.respond(request, response, stream)
                                    
                                case .next(let request, let response):
                                    self.respondError(MiddlewareError.noNextMiddleware, request, response, stream)
                                    
                                case .error(let error):
                                    self.respondError(error, request, response, stream)
                                }
                            }
                            
                        case .error(let error):
                            self.respondError(error, request, response, stream)
                        }
                    }
                } else {
                    let error = RoutingError.routeNotFound(path: request.path ?? "/")
                    self.respondError(error, request, response, stream)
                }
                
            case .error(let error):
                self.respondError(error, request, Response(), stream)
            }
        }
    }
    
    private func respondError(_ error: Error, _ request: Request, _ response: HTTPCore.Response, _ stream: DuplexStream){
        self.catchHandler(MiddlewareError.noNextMiddleware, request, response) { [unowned self] chainer in
            var response = response
            switch chainer {
            case .respond(let response):
                self.respond(request, response, stream)
                
            case .next(_):
                response.status(.internalServerError)
                response.text("\(MiddlewareError.noNextMiddleware)")
                self.respond(request, response, stream)
                
            case .error(_):
                response.status(.internalServerError)
                response.text("Something went wrong.")
                self.respond(request, response, stream)
            }
        }
    }
    
    private func respond(_ request: HTTPCore.Request, _ response: HTTPCore.Response, _ stream: DuplexStream){
        var response = response
        response.headers["Server"] = "Slimane"
        
        if response.contentType == nil {
            response.contentType = mediaType(forFileExtension: "html")!
        }
        
        ResponseSerializer(stream: stream).serialize(response) { [unowned self] result in
            if case .failure(_) = result {
                return stream.close()
            }
            
            self.finallyHandler(request, response)
            
            if let upgradeConnection = response.upgradeConnection {
                upgradeConnection(request, stream)
            }
            
            if !request.isKeepAlive && response.upgradeConnection == nil {
                stream.close()
            }
        }
    }
}
