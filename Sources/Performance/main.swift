import Slimane

do {
    let app = Slimane()
    
    app.get("/") { req, responder in
        responder {
            Response(body: "Hello, world")
        }
    }

    try app.listen()
} catch {
    fatalError("\(error)")
}
