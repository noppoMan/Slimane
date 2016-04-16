# Slimane

<img src="https://raw.githubusercontent.com/noppoMan/Slimane/master/logo/Slimane_logo.jpg" width=250>

## OverView
Slimane is an express inspired web framework for Swift that works on OSX and Ubuntu.


- [x] Completely Asynchronous
- [x] Unopinionated and Minimalist
- [x] Adopts [Open Swift](https://github.com/open-swift)
- [ ] Feature/Promise Support

### A Work In Progress
Slimane is currently in active development.  
Feel free to contribute, pull requests are welcome!

### Attension
It works as a completely asynchronous and the core runtime is created with [libuv](https://github.com/libuv/libuv).  
**So Don't stop the event loop with the CPU heavy tasks.**  
[Guide of working with the cpu heavy tasks](https://github.com/noppoMan/Slimane/wiki/guide-of-working-with-the-cpu-heavy-tasks)


## Considering/In developing
* Streaming Response
* Deal with Mysql via asynchronous networking
* Promise Support
* Various Responder : ex `responder { Render(path: "foo.mustache", variables: [:]) }`
* Command line interface

## Getting Started

### Install Guide
[Here is install guides for each operating systems](https://github.com/noppoMan/Slimane/wiki/Install-Guide)

### Documentation
[Here is Documentation for Slimane.](https://github.com/noppoMan/Slimane/wiki)


## Usage

Starting the application takes slight lines.

More Example? Visit [slimane-example](https://github.com/slimane-swift/slimane-example)

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
Middleware is functions that have access to the http request, the http response, and the next function in the application' s request-response cycle.

See more to visit https://github.com/slimane-swift/Middleware

We have 3 registration types for that

### MiddlewareType
```swift

struct AccessLogMiddleware: MiddlewareType {
    func respond(req: Request, res: Response, next: MiddlewareChain) {
        print("[\(Suv.Time())] \(req.uri.path ?? "/")")
        next(.Chain(res))
    }
}

app.use(AccessLogMiddleware())
```

### AsyncMiddleware
Can pass the Open-Swift's AsyncMiddleware confirming Middleware

```swift
struct AccessLogMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder, result: (Void throws -> Response) -> Void) {
        next.respond(to: request, result: {
            do {
                let response = try $0()
                print("[\(Suv.Time())] \(req.uri.path ?? "/")")
                result { response }
            } catch {
              result { throw error }
            }
        })
    }
}

app.use(AccessLogMiddleware())
```

### Handy

```swift
app.use { req, res, next in
    print("[\(Suv.Time())] \(req.uri.path ?? "/")")
    next(.Chain(res))
}
```

### Intercept Response

Can intercept response at the middleware with passing any values the Response.body object.
It means, **never reaches** next middleware chains and the route.

```swift
app.use { req, res, next in
    var res = res // first, response object is immutable.
    res.body("Intercepted at the middleware")
    next(.Chain(res))
}
```

## Request/Response

We are using S4.Request and S4.Response
See more detail, please visit https://github.com/open-swift/S4


## Session/Cookie
Getting ready

## Body Data

### JSON
Getting ready

### Form Data
Getting ready


### Handling Errors

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
* 0.2x: Here. There should be significant changes from 0.1x due to adopting [open-swift](https://github.com/open-swift).

## Package.swift

```swift
import PackageDescription

let package = Package(
      name: "MyApp",
      dependencies: [
          .Package(url: "https://github.com/noppoMan/Slimane.git", majorVersion: 0, minor: 2),
      ]
)
```

## License

Slimane is released under the MIT license. See LICENSE for details.
