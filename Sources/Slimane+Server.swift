//
//  Serve.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    public func listen(loop: Loop = Loop.defaultLoop, host: String = "0.0.0.0", port: Int = 3000, errorHandler: (ErrorProtocol) -> () = { _ in }) throws {
        let server = Skelton(loop: loop, ipcEnable: Cluster.isWorker) { [unowned self] in
            do {
                let (request, stream) = try $0()
                self.dispatch(request, stream: stream)
            } catch {
                errorHandler(error)
            }
        }

        server.setNoDelay = self.setNodelay
        server.keepAliveTimeout = self.keepAliveTimeout
        server.backlog = self.backlog
        
        if self.middlewares.count == 0 {
            // Register dummy middleware to suppress error
            self.use { request, next, result in
                next.respond(to: request, result: result)
            }
        }

        if Cluster.isMaster {
            try server.bind(host: host, port: port)
        }
        try server.listen()
    }

    private func dispatch(_ request: Request, stream: HTTPStream){
        let responder = BasicAsyncResponder { [unowned self] request, result in
            if let route = self.router.match(request) {
                var request = request
                request.params = route.params(request)
                route.handler.respond(to: request) { response in
                    result {
                        try response()
                    }
                }
            } else {
                result {
                    self.errorHandler(Error.RouteNotFound(path: request.uri.path ?? "/"))
                }
            }
        }
        
        self.middlewares.chain(to: responder).respond(to: request) { [unowned self] in
            do {
                let response = try $0()
                if let responder = response.customResponder {
                    responder.respond(response) { getResponse in
                        do {
                            processStream(try getResponse(), request, stream)
                        } catch {
                            self.handleError(error, request, stream)
                        }
                    }
                } else {
                    processStream(response, request, stream)
                }
            } catch {
                self.handleError(error, request, stream)
            }
        }
    }
    
    private func handleError(_ error: ErrorProtocol, _ request: Request, _ stream: HTTPStream){
        processStream(errorHandler(error), request, stream)
    }
}

private func processStream(_ response: Response, _ request: Request, _ stream: HTTPStream){
    var response = response
    
    response.headers["Date"] = Time().rfc1123
    
    response.headers["Server"] = "Slimane"
    
    if response.headers["Connection"] == nil {
        response.headers["Connection"] = request.shouldKeepAlive ? "Keep-Alive" : "Close"
    }
    
    if response.contentLength == 0 && !response.isChunkEncoded {
        response.contentLength = response.bodyLength
    }
    
    AsyncHTTPSerializer.ResponseSerializer().serialize(response, to: stream)
    closeStreamIfNeeded(response, stream)
}

private func closeStreamIfNeeded(_ response: Response, _ stream: HTTPStream){
    if !response.shouldKeepAlive {
        do { try stream.close() } catch {}
    }
}
