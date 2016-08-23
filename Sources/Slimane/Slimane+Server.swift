//
//  Serve.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    
    public var clientsConnected: Int {
        return server?.clientsConnected ?? 0
    }
    
    public func closeAllClientsConnection() {
        guard let sockets = self.server?.socketsConnected else {
            return
        }
        
        for socket in sockets {
            do { try socket.close() } catch { }
        }
    }
    
    public func listen(loop: Loop = Loop.defaultLoop, host: String = "0.0.0.0", port: Int = 3000, errorHandler: @escaping (Error) -> () = { _ in }) throws {
        self.server = Skelton(loop: loop, ipcEnable: Cluster.isWorker) { [unowned self] in
            do {
                let (request, stream) = try $0()
                self.dispatch(request, stream: stream)
            } catch {
                errorHandler(error)
            }
        }

        server?.setNoDelay = self.setNodelay
        server?.keepAliveTimeout = self.keepAliveTimeout
        server?.backlog = self.backlog

        if Cluster.isMaster {
            try server?.bind(host: host, port: port)
        }
        try server?.listen()
    }

    private func dispatch(_ request: Request, stream: HTTPStream){
        let responder = BasicAsyncResponder { [unowned self] request, result in
            if let route = self.router.match(request) {
                var request = request
                request.params = route.params(request)
                route.middlewares.chain(to: route.handler).respond(to: request, result: result)
            } else {
                result {
                    self.errorHandler(RoutingError.routeNotFound(path: request.uri.path ?? "/"))
                }
            }
        }
        
        self.middlewares.chain(to: responder).respond(to: request) { [unowned self] getResponse in  
            do {
                let response = try getResponse()
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
    
    private func handleError(_ error: Error, _ request: Request, _ stream: HTTPStream){
        processStream(errorHandler(error), request, stream)
    }
}

private func processStream(_ response: Response, _ request: Request, _ stream: HTTPStream){
    var response = response
    
    response.headers["Date"] = Time().rfc1123
    
    response.headers["Server"] = "Slimane"
    
    if response.contentLength == nil && !response.isChunkEncoded {
        response.contentLength = response.bodyLength
    }
    
    AsyncHTTPSerializer.ResponseSerializer(stream: stream).serialize(response) { result in
        do {
            try result()
            if let didUpgradeAsync = response.didUpgradeAsync {
                didUpgradeAsync(request, stream)
            }
        } catch {
            do { try stream.close() } catch {}
        }
    }
    
    if !request.isKeepAlive && response.didUpgradeAsync == nil {
        do { try stream.close() } catch {}
    }
}
