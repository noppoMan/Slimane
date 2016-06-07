# Slimane

<img src="https://raw.githubusercontent.com/noppoMan/Slimane/master/logo/Slimane_logo.jpg" width=250>

## OverView
Slimane is an express inspired web framework for Swift that works on OSX and Ubuntu.


- [x] Completely Asynchronous
- [x] Unopinionated and Minimalist
- [x] Adopts [Open Swift](https://github.com/open-swift)


### A Work In Progress
Slimane is currently in active development.  
Feel free to contribute, pull requests are welcome!

### Attension
It works as a completely asynchronous and the core runtime is created with [libuv](https://github.com/libuv/libuv).  
**So Don't stop the event loop with the CPU heavy tasks.**  
[Guide of working with the cpu heavy tasks](https://github.com/noppoMan/Slimane/wiki/guide-of-working-with-the-cpu-heavy-tasks)

## Slimane Project Page 🎉
Various types of libraries are available from here.

https://github.com/slimane-swift

## Community
The entire Slimane code base is licensed under MIT. By contributing to Slimane you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](https://slimane-swift-slackin.herokuapp.com/) to get to know us!

## Getting Started

### Install Guide
[Here is install guides for each operating systems](https://github.com/noppoMan/Slimane/wiki/Install-Guide)

### Documentation
[Here is Documentation for Slimane.](https://github.com/noppoMan/Slimane/wiki)

## Usage

Starting the application takes slight lines.

```swift
import Slimane

let app = Slimane()

app.get("/") { req, responder in
    responder {
      Response(body: "Welcome Slimane!")
    }
}

try! app.listen()
```

### Example Project

https://github.com/slimane-swift/slimane-example

## Routing

```swift
app.get("/articles/:id") { req, responder in
    responder {
        Response(body: "Article ID is: \(req.params["id"]!)")
    }
}
```

#### Methods
* get
* options
* post
* put
* patch
* delete


## Middlewares
Middleware is functions that have access to the http request, the http response, and the next function in the application' s request-response cycle. We offers 3 types of registration ways for that.

See more to visit https://github.com/slimane-swift/Middleware

### MiddlewareType
```swift

struct AccessLogMiddleware: MiddlewareType {
    func respond(req: Request, res: Response, next: MiddlewareChain) {
        print("[\(Suv.Time())] \(req.uri.path ?? "/")")
        next(.Chain(req, res))
    }
}

app.use(AccessLogMiddleware())
```

### AsyncMiddleware
It's able to accept Open-Swift's AsyncMiddleware confirming Middleware

```swift
struct AccessLogMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder, result: (Void throws -> Response) -> Void) {
        print("[\(Suv.Time())] \(request.path ?? "/")")
        next.respond(to: request) { response in
            result {
                try response()
            }
        }
    }
}

app.use(AccessLogMiddleware())
```

### Handy

```swift
app.use { req, res, next in
    print("[\(Suv.Time())] \(req.uri.path ?? "/")")
    next(.Chain(req, res))
}
```

### Intercept Response

You sometimes want to intercept `Response` in the middleware.(For example, serving static files, authentication etc..) Under the those cases, You can intercept it with `MiddlewareChainResult.Intercept` like the following.

```swift
app.use { req, res, next in
    // Respond to the content soon and it's never reached the next chains and the route.
    next(.Intercept(req, res))
}
```

## Request/Response

We are using S4.Request and S4.Response
See more detail, please visit https://github.com/open-swift/S4

## Static Files/Assets

Just register the `Slimane.Static()` into middleware chains

```swift
app.use(Slimane.Static(root: "/path/to/your/public"))
```

## Cookie

#### request.cookies: `Set<Cookie>`

request.cookies is Readonly.
```swift
req.cookies["session-id"]
```

**Cookie** is declared in S4. See more to visit https://github.com/open-swift/S4

#### response.cookies: `Set<AttributedCookie>`

response.cookies is Writable.

```swift
let setCookie = AttributedCookie(....)
res.cookies = Set<setCookie>
```
**AttributedCookie** is declared in S4. See more to visit https://github.com/open-swift/S4


## Session

Register SessionMiddleware into the middleware chains.
See more detail for SessionMiddleware to visit https://github.com/slimane-swift/SessionMiddleware

```swift
import Slimane
import SessionMiddleware

let app = Slimane()

// SessionConfig
let sesConf = SessionConfig(
    secret: "my-secret-value",
    expires: 180,
    HTTPOnly: true
)

// Enable to use session in Slimane
app.use(SessionMiddleware(conf: sesConf))

app.get("/") { req, responder
    // set data into the session
    req.session["foo"] = "bar"

    req.session.id // show session id

    responder {
        Response()
    }
}
```

### Available Session Stores
* MemoryStore
* SessionRedisStore


## Body Data

Register BodyParser into the middleware chains.

```swift
app.use(BodyParser())
```

#### request.json `Zewo.JSON`

Can get parsed json data throgh the req.json when content-type is `application/json`

```swift
req.json?["foo"]
```

#### request.formData `[String: String]`

Can get parsed form data throgh the req.formData when content-type is `application/x-www-form-urlencoded`

```swift
req.formData?["foo"]
```

## Views/Template Engines
* Add the [Render](https://github.com/slimane-swift/Render) module into the Package.swift
* Add the [MustacheViewEngine](https://github.com/slimane-swift/MustacheViewEngine) module into the Package.swift

Then, You can use render function in Slimane. and pass the render object to the `custome` label for Response initializer.

```swift
app.get("/render") { req, responder in
    responder {
        let render = Render(engine: MustacheViewEngine(templateData: ["foo": "bar"]), path "index")
        Response(custome: render)
    }
}
```

## Create your own ViewEngine

Getting ready

## Working with Cluster

A single instance of Slimane runs in a single thread. To take advantage of multi-core systems the user will sometimes want to launch a cluster of Slimane processes to handle the load.


Here is an easy example for working with Suv.Cluster

```swift
// For Cluster app
if Cluster.isMaster {
    for _ in 0..<OS.cpuCount {
        var worker = try! Cluster.fork(silent: false)
        observeWorker(&worker)
    }

    try! Slimane().listen()
} else {
    let app = Slimane()
    app.use("/") { req, responder in
        responder {
            Response(body: "Hello! I'm \(Process.pid)")
        }
    }

    try! app.listen()
}
```

## IPC between Master and Worker Processes

Inter process message between master and workers

### On Master
```swift
var worker = try! Cluster.fork(silent: false)

// Send message to the worker
worker.send(.Message("message from master"))

// Receive event from the worker
worker.on { event in
    if case .Message(let str) = event {
        print(str)
    }

    else if case .Online = event {
        print("Worker: \(worker.id) is online")
    }

    else if case .Exit(let status) = event {
        print("Worker: \(worker.id) is dead. status: \(status)")
        worker = try! Cluster.fork(silent: false)
        observeWorker(&worker)
    }
}
```

### On Worker
```swift

// Receive event from the master
Process.on { event in
    if case .Message(let str) = event {
        print(str)
    }
}

// Send message to the master
Process.send(.Message("Hey!"))
```

## Respond to the Streaming Content

You can respond to the streaming content with `Body.asyncSender`
Here is an example for websocket response with [WS](https://github.com/slimane-swift/WS)

```swift
import WS
import Slimane

let app = Slimane()

app.get("/chat") { req, responder in
    responder {
        var response = Response()
        response.body = .asyncSender({ stream, _ in
                // upgrade and get socket
                WebSocketServer(to: req, with: stream) {
                    do {
                        let socket = try $0()
                        socket.onPing {
                            socket.pong($0)
                            print($0)
                        }
                    } catch {
                        print(error)
                        stream.close()
                    }
                }
            }
        })
        return response
    }
}

try! app.listen()
```

## Extras

### Working with blocking functions
We have [QWFuture](https://github.com/slimane-swift/QWFuture) to run blocking functions in a separate thread with future syntax as you know.

It allows potentially any third-party libraries to be used with the event-loop paradigm. For more detail, visit https://github.com/slimane-swift/QWFuture

Here is an

```swift
import QWFuture

let future = QWFuture<AnyObject> { (result: (() throws -> AnyObject) -> ()) in
    result {
        let db = DB(host: "localhost")
        retrun try db.executeSync("insert into users (id, name) values (1, 'jack')") // blocking
    }
}

future.onSuccess {
    print($0)
}

future.onFailure {
    print($0)
}
```

### Promise
We have [Thrush](https://github.com/noppoMan/Thrush) to use Promise apis in the app to make beautiful asynchronous flow.
Thrush has similar apis to the [ES promise](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Promise).
For more detail, visit https://github.com/noppoMan/Thrush

Here is a replacement codes of the [Working with blocking functions](working-with-blocking-functions) section with `Promise`

```swift
import Thrush
import QWFuture

extension DB {
    func execute(sql: String) -> Promise<AnyObject> {
        return Promise<AnyObject> { resolve, reject in
            let future = QWFuture<AnyObject> { [unowned self] (result: (() throws -> AnyObject) -> ()) in
                result {
                    try self.executeSync(sql) // blocking api
                }
            }

            // fulfilled
            future.onSuccess {
                resolve($0)
            }

            // reject
            future.onFailure {
                reject($0)
            }
        }
    }
}

let db = DB(host: "localhost")

db.execute("insert into users (id, name) values (1, 'jack')").then {
    print($0)
}
.failure {
    print($0)
}
.finally {
    print("Done")
}
```


## Handling Errors

Easy to override Default Error Handler with replace `app.errorHandler` to your costume handler.
All of the errors that occurred in Slimane's lifecycles are passed as first argument of errorHandler even RouteNotFound.

```swift
let app = Slimane()

app.errorHandler = myErrorHandler

func myErrorHandler(error: ErrorProtocol) -> Response {
    let response: Response
    switch error {
        case Costume.InvalidPrivilegeError
            response = Response(status: .forbidden, body: "Forbidden")
        case Costume.ResourceNotFoundError(let name)
            response = Response(status: .notFound, body: "\(name) is not found")
        default:
            response = Response(status: .badRequest, body: "\(error)")
    }

    return response
}

try! app.listen()
```

#### Note
Synchronous style ErrorHandler will be replaced to asynchronous.


## Versions
* 0.1x: https://github.com/noppoMan/Slimane/tree/0.1.2
* 0.2x: There should be significant changes from 0.1x due to adopting [open-swift](https://github.com/open-swift).
* 0.3x: There should be internal changes for working with swift-DEVELOPMENT-SNAPSHOT-2016-04-25-a
* 0.4x: There should be internal changes for working with swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a
* 0.5x: There should be internal changes for working with swift-DEVELOPMENT-SNAPSHOT-2016-05-31-a

## Package.swift

```swift
import PackageDescription

let package = Package(
      name: "MyApp",
      dependencies: [
          .Package(url: "https://github.com/noppoMan/Slimane.git", majorVersion: 0, minor: 5),
      ]
)
```

## License

Slimane is released under the MIT license. See LICENSE for details.
