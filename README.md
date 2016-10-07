# Slimane

<img src="https://raw.githubusercontent.com/noppoMan/Slimane/master/logo/Slimane_logo.jpg" width=250>

## OverView
Slimane is an express inspired web framework for Swift that works on OSX and Ubuntu.


- [x] 100% Asynchronous
- [x] Unopinionated and Minimalist
- [x] Incredible Performance

## Benchmark

Getting ready

## Slimane Project Page 🎉
Various types of libraries are available from here.

https://github.com/slimane-swift

## Community
The entire Slimane code base is licensed under MIT. By contributing to Slimane you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](https://slimane-swift-slackin.herokuapp.com/) to get to know us!

## Getting Started

### Install Guide
[Here is an install guides for each operating systems](https://github.com/noppoMan/Slimane/wiki/Install-Guide)

## Usage

Starting the application takes slight lines.

```swift
import Slimane

let app = Slimane()

app.use(.get, "/") { request, response, responder in
    var response = response
    response.text("Welcome to Slimane!")
    responder(.respond(response))
}

try! app.listen()
```

### Generate a new Slimane App via slimane-cli(Requires Node.js v4 or later)
```sh
npm i -g slimane-cli
```

```sh
slimane new YourAppName
cd YourAppName
slimane build
slimane run
```

**That's it!**

## Routing

```swift
app.use(.get, "/articles/:id") { request, response, responder in
    var response = response
    response.text("Article ID is: \(req.params["id"]!)")
    responder(.respond(response))
}
```

#### Methods
* get
* options
* post
* put
* patch
* delete
* other(method: String)


## Middlewares
Middleware is functions that have access to the http request, the http response, and the next function in the application' s request-response cycle.

### Handy

```swift
app.use { request, response, responder in
    do {
        try doSomething()
        responder(.next(request, response)) // Chaining to the next middleware or route
    } catch {
        responder(.error(error)) // Go to `catch` handler
    }
}
```

### Middleware Protocol

```swift
struct FooMiddleware: Middleware {
    func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
      do {
          try doSomething()
          responder(.next(request, response)) // Chaining to the next middleware or route
      } catch {
          responder(.error(error)) // Go to `catch` handler
      }
    }
}

app.use(FooMiddleware())
```

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

#### response.cookies: `Set<AttributedCookie>`

response.cookies is Writable.

```swift
let setCookie = AttributedCookie(....)
res.cookies = Set<setCookie>
```

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

app.use(.get, "/") { request, response, responder in
    var request = request
    // set data into the session
    request.session["foo"] = "bar"

    request.session.id // show session id

    response(.respond(response))
}
```

### Available Session Stores
* MemoryStore
* SessionRedisStore


## Body Data

Register BodyParser into the middleware chains.

#### request.json `SwiftyJSON.JSON`

Can get parsed json data throgh the req.json when content-type is `application/json`

```swift
app.use(BodyParser.JSON())
```

```swift
request.json?["foo"]
```

#### request.formData `URLEncodedForm`

Can get parsed form data throgh the req.formData when content-type is `application/x-www-form-urlencoded`

```swift
app.use(BodyParser.URLEncoded())
```

```swift
request.formData?["foo"]
```

## Views/Template Engines
* Add the [Render](https://github.com/slimane-swift/Render) module into the Package.swift
* Add the [MustacheViewEngine](https://github.com/slimane-swift/MustacheViewEngine) module into the Package.swift

Then, You can use render function in Slimane with following code.

```swift
app.get("/render") { request, response, responder in
    var response = response
    response.render(MustacheViewEngine("index", templateData: ["foo": "bar"]))
    responder(.respond(response))
}
```

## Working with Cluster

A single instance of Slimane runs in a single thread. To take advantage of multi-core systems the user will sometimes want to launch a cluster of Slimane processes to handle the load.


Here is an easy example for working with Suv.Cluster

```swift
// For Cluster app
if Cluster.isMaster {
    for _ in 0..<OS.cpus().count {
        let worker = try! Cluster.fork(silent: false)
    }

    try! Slimane().listen()
} else {
    let app = Slimane()
    app.get("/") { request, response, responder in
        var response = response
        response.text("Hello! process id is \(Process.pid)")
        responder(.respond(response))
    }

    try! app.listen()
}
```

## IPC between Master and Worker Processes

### On Master
```swift
var worker = try! Cluster.fork(silent: false)

// Send message to the worker
worker.send(.Message("message from master"))

// Receive event from the worker
worker.onEvent { event in
    if case .message(let str) = event {
        print(str)
    }

    else if case .online = event {
        print("Worker: \(worker.id) is online")
    }

    else if case .exit(let status) = event {
        print("Worker: \(worker.id) is dead. status: \(status)")
        let worker = try! Cluster.fork(silent: false)
        observeWorker(worker)
    }
}
```

### On Worker
```swift

// Receive event from the master
Process.onEvent { event in
    if case .message(let str) = event {
        print(str)
    }
}

// Send message to the master
Process.send(.message("Hey!"))
```

## Life Cycle

## Handling Errors

You can catch the error that are emitted from the middleware or the route with `app.catch` handler.

```swift
let app = Slimane()

app.use { request, response, responder in
    responder(.error(FooError))
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
        response.text("\(error)") // fooError
    }

    responder(.respond(response))
}

try! app.listen()
```

## Finalization

After responded to the content, You can process finalization for the request with `app.finally` block.
Here is a logging example for the request.

```swift

let app = Slimane()

app.use(.get, "/") { request, response, responder in
    var response = response
    response.text("Welcome to Slimane!")
    responder(.respond(response))
}

app.finally { request, response in
  print("\(request.method) \(request.path ?? "/") \(response.status.statusCode)") // GET / 200
}

try! app.listen()
```


## Extras

### WebSocket

You can respond to the streaming content with `Body.writer`
Here is an example for processing streaming content with [WS](https://github.com/slimane-swift/WS)

```swift
import WS
import Slimane

let app = Slimane()

let wsServer = WebSocketServer { socket, request in
    socket.onText { text in
        socket.send("PONG")
    }
}

app.use(wsServer)

try! app.listen()
```


### Working with blocking functions
We have `Process.qwork` to run blocking functions in a separated thread.

It allows potentially any third-party libraries to be used with the event-loop paradigm.

```swift
let onThread = { ctx in
    do
        ctx.storage["result"] = try blokingOperation()
    } catch {
        ctx.storage["error"] = error
    }
}

let onFinish = { ctx in
    if let error = ctx.storage["error"] as? Error {
        print(error)
        return
    }

    print(ctx.storage["result"])
}

Process.qwork(onThread: onThread, onFinish: onFinish)
```

### Promise
We have [Thrush](https://github.com/noppoMan/Thrush) to use Promise apis in the app to make beautiful asynchronous flow.
Thrush has similar apis to the [ES promise](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Promise).
For more detail, visit https://github.com/noppoMan/Thrush

Here is a replacement codes of the [Working with blocking functions](#working-with-blocking-functions) section with `Promise`

```swift
import Thrush

extension DB {
    func execute(sql: String) -> Promise<FooResult> {
        return Promise<FooResult> { resolve, reject in
            let onThread = { ctx in
                do
                    ctx.storage["result"] = try blockingSqlQuery(sql)
                } catch {
                    ctx.storage["error"] = error
                }
            }

            let onFinish = { ctx in
                if let error = ctx.storage["error"] as? Error {
                    reject(error)
                    return
                }

                resolve(ctx.storage["result"] as! FooResult)
            }

            Process.qwork(onThread: onThread, onFinish: onFinish)
        }
    }
}

let db = DB(host: "localhost")

db.execute("insert into users (id, name) values (1, 'jack')").then {
    print($0)
}
.`catch` {
    print($0)
}
.finally {
    print("Done")
}
```


## Package.swift

```swift
import PackageDescription

let package = Package(
      name: "MySlimaneApp",
      dependencies: [
          .Package(url: "https://github.com/noppoMan/Slimane.git", majorVersion: 0, minor: 9),
      ]
)
```

## License

Slimane is released under the MIT license. See LICENSE for details.
