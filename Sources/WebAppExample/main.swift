//
//  main.swift
//  Slimane
//
//  Created by Yuki Takei on 2016/10/07.
//
//

import Slimane

let app = Slimane()

app.use(Slimane.Static(root: "\(Process.cwd)"))
app.use(BodyParser.JSON())

app.use(.post, "/json") { request, response, responder in
    var response = response
    response.status(.created)
    response.json(request.json ?? ["message": "non json body"])
    responder(.respond(response))
}

app.use(.get, "/") { request, response, responder in
    var response = response
    response.text("<html><head><title>Slimane Example App</title></head><body>Welcome to Slimane!</body></html>")
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
