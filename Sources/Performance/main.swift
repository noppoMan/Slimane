import Slimane

if Cluster.isMaster {
    for _ in 0..<ProcessInfo.cpus().count {
        var worker = try! Cluster.fork(silent: false)
    }
    
    try! _ = Slimane().listen()
} else {
    let app = Slimane()
    
    //app.use(Slimane.Static(root: "\(Process.cwd)"))
    
    app.use(.get, "/") { request, response, responder in
        var response = response
        response.text("Welcome to Slimane!")
        responder(.respond(response))
    }
    
    app.`catch` { error, request, response, responder in
        var response = response
        switch error {
        case RoutingError.routeNotFound:
            response.status(.notFound)
            response.text("\(error)")
            
        case StaticMiddlewareError.resourceNotFound:
            response.status(.notFound)
            response.text("\(error)")
            
        default:
            response.status(.internalServerError)
            response.text("\(error)")
        }
        
        responder(.respond(response))
    }
    
    app.finally { request, response in
        print("\(request.method) \(request.path ?? "/") \(response.status.statusCode)")
    }
    
    print("Started HTTP server at 0.0.0.0:3000")
    try! app.listen()
}
