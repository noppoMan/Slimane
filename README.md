# Slimane
An express inspired web framework for swift

<img src="https://raw.githubusercontent.com/noppoMan/Slimane/master/logo/Slimane_logo.jpg" width=250>


### A Work In Progress
Slimane is currently in active development.  
Feel free to contribute and pull requests are welcome!

## Table of Contents

* [Getting Started](#getting-started)
  * [Install Guide](#install-guide)
  * [Documentation](#documentation)
  * [Example Project](#example-project)
* [Usage](#usage)
* [Routing](#routing)
* [Middleware](#middleware)
  * [Body Parser](#body-parser)
  * [Cookie and Session](#cookie-and-session)
  * [Static File Serving](#static-file-serving)
* [Request](#request)
  * [URI Params](#uri-params)
  * [Query String](#query-string)
  * [Request Header](#request-header)
  * [JSON Data](#json-data)
  * [Form Data](#form-data)
* [Response](#response)
  * [Response Header](#response-header)
  * [Response Status](#response-status)
  * [View/Render](#respond-text-with-template-engine)
  * [Plain Text](#plain-text)
  * [Binary Content](#binary-content)

* [Cluster and Worker](#cluster-and-worker)
* [Filters](#filters)
* [Error Handling](#error-handling)
* Deal with Database/Other Data Store
* Deploying

## Getting Started


### Install Guide
[Here is install guides for each operating systems](https://github.com/noppoMan/Slimane/wiki/Install-Guide)

### Documentation
[Here is Documentation for Slimane.](https://github.com/noppoMan/Slimane/wiki)

### Example Project
[Check out the Example Project to start development with Slimane.](https://github.com/noppoMan/Slimane/wiki#example-project)

## Usage
The usage of Slimane is similar with [express](https://github.com/expressjs/express)  
Example Project is [here](https://github.com/noppoMan/slimane-example)

```swift
import Slimane

let app = Slimane()

app.use(BodyParser())

app.use(CookieParser())

app.use(SessionHandler(
    SessionConfig(
        secret: "secret",
        expires: Time(tz: .UTC).addDay(7).rfc822
    )
))

app.use(StaticFileServe())


app.get("/") { req, res in
    res.write("Welcome to Slimane!")
}

// Bind address, port and listen http server
try! app.listen(host: "127.0.0.1", port: 3000)
```

## Routing

Slimane's router is simple and similar with Express routing.

### Available http methods for routing
* get
* post
* put
* patch
* delete

### Routing with RouteType
```swift
struct UserCreateRoute: RouteType {
    func handleRequest(req: Request, res: Response) throws {
        guard let json = req.jsonBody, let _name = json["name"], userName = _name.stringValue else {
            throw CustomErrorType("name is required")
        }

        DB.query("INSERT INTO users (name) values (?)", userName) { err, result in
          if(err) {
            return res.status(.BadRequest).write("Something went wrong")
          }

          res.write("The user \(userName) was created")
        }
    }
}

app.post("/user", UserCreateRoute)
```

### Handy routing
```swift
app.post("/user") { req, res in
  res.write("Hello world!")
}
```


## Middleware

Middleware is functions that have access to the http request, the http response, and the next function in the application' s request-response cycle.

If the next function is not called, request-response cycle is stopped or should call res.write to end request in the middleare.

### MiddlewareType
```swift
struct BodyParser: MiddlewareType {
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws {

        guard let body = req.bodyString, let contentType = req.contentType else {
            next(nil)
            return
        }

        switch(contentType.type) {
        case "application/json":
            req.context["jsonBody"] = try! JSONParser.parse(body)

        case "application/x-www-form-urlencoded":
            req.context["formData"] = parseURLEncodedString(body)

        default:
            print("Unkown content type")
        }

        next(nil)
    }
}

app.use(BodyParser())

// of course you can register middleware as following
app.use(BodyParser().handleRequest) // app.use { req, res, next in ... }
```

### Handy
```swift
app.use { req, res, next in

  // write some middlware logic

  next(nil)
}
```

## Body Parser

Parse http body data depends on Content-Type.

#### Status
* application/json: Ready
* application/x-www-form-urlencoded: Ready
* application/xml: Not implemented yet
* multipart/form-data: Not implemented yet

Default is `application/x-www-form-urlencoded`

### Access to parsed body data from request
[See request directive](#request)

## Cookie and Session

Register CookieParser and SessionHandler into middleware chain then You can use session.

``` swift
app.use(CookieParser(secret: "secret"))

let t = Time(tz: .UTC) // Time class is declared in Suv
t.addDay(7)

let sesConf = SessionConfig(
  keyName: "my-session-id",
  secret: "secret",
  expires: t.rfc822
)

app.use(SessionHandler(sesConf))

app.use { req, res, next in

  print(req.sessionId) // see current session id

  req.session["bar"] = "session value"
  next(nil)
}

app.get("/foo") { req, res in
  res.write(req.session["bar"] as! String)
}
```

## Static File Serving
Just add StaticFileServe() into middelware chain.

```swift

 // Pass the document root for static assets to StaticFileServe.
app.use(StaticFileServe("/path/to/public/"))

```


## Request

### URI Params

Pick a param in URI such as `/users/:id` from req.params

```swift
// If The Requested URL is Get /users/200 ...

app.use { req, res, next in
  req.params["id"] // 200
}
```


### Query String

Pick a query string in URI from req.query

```swift
// If The Requested URL is Get /users?id=200 ...

app.use { req, res, next in
  req.query["id"] // 200
}
```

### Request Header

Show all request headers and pick a value for key

```swift
app.use { req, res, next in

  // Show all request headers
  req.headers

  // Get a header value for key
  req.getHeader("Connection") // Keep-Alive
}
```

### JSON Data

Access the JSON data through the req.jsonBody
req.jsonBody is optional computed value

**First, Need to add BodyParser into middleware chain**

```swift
app.use { req, res, next in
  req.jsonBody?["foo"]
}
```

### Form Data

Access the Form data through the req.formData?
req.formData is optional computed value

**First, Need to add BodyParser into middleware chain**

```swift
app.use { req, res, next in
  req.formData?["bar"]
}
```


## Response

### Response Header

Set response header with res.setHeader method


```swift
app.use { req, res, next in
  res.setHeader("Connection", "Keep-Alive")
}
```

### Response Status

Set response status with res.status method
[The available Statuses are here](https://github.com/Zewo/HTTP/blob/5a3f4181e202ebe811334b3e11bf3886f724cbf6/Sources/Status.swift)

```swift
app.use { req, res, next in
  res.status(.OK).write("foobar")
}
```

### View/Render

Currently Slimane does not provide template engine.
But that's easy to implement with existing template engine in swift.
See [Example](https://github.com/noppoMan/slimane-example/blob/master/Sources/Response%2BMustacheRender.swift) of adding `render` method into response


### Plain Text

Call res.write to write data to client.
Write method can take String, Buffer and [Int8] byte array.

The Buffer class is generic data type in Suv

```swift
app.get("/") { req, res in
    res.write("Welcome Slimane!")
}
```


### Binary Content

Respond binary data. Here is streaming response sample

```swift
app.get("/binary-content") { req, res in
    // specify Transfer-Encoding header
    res.setHeader("Transfer-Encoding", "Chunked")
    res.writeHead() // write head

    let fs = FileSystem(path: "/path/to/unkown-size-image.png") // FileSystem is declared in Suv

    fs.read(.R) {
      if case .Error(let error) = result {

        fs.close()

        // Write Error and end response
        res.write("\(error)")
        res.end()

      } else if case .Data(let buffer) = result {

        // Write chunk
        res.write(buffer)

      } else {
          fs.close()

          // Write 0\r\n\r\n to close stream.
          res.end()
      }
    }
}

```


## Filters
Filters are the middleware and are individual functions that make up the request processing pipeline.

### Available filters
* `beforeWrite`: before write packet to client
* `afterWrite`: after write packet to client

#### Sample of registering callbacks
```swift
app.use { req, res next in

  req.appendBeforeWriteCallback({
    print("before1")
  })

  req.appendBeforeWriteCallback({
    print("before2")
  })

  req.appendAfterWriteCallback({
    print("after1")
  })

  req.appendAfterWriteCallback({
    print("after2")
  })

  next(nil)
}

app.get("/") { req, res in
  res.write("OK")
  /*
  * 1. before1 printed
  * 2. before2 printed
  * 3. Write message(OK) packet
  * 4. after1 printed
  * 5. after2 printed
  */
}

```

## Cluster and Worker
#### Working on Multiprocess Environment

A single instance of Slimane runs in a single thread.  
To take advantage of multi-core systems the user will sometimes want to launch a cluster of Slimane processes to handle the load.  

Suv.Cluster module enable you to easily create own child processes.(It's like node.js cluster module interface)

#### Attension
First, You need to bind and listen server on master process.
Because current Suv.Cluster doesn't support interprocess communication between master and worker without shared connection.
So worker can not send proxy request that listen server at its specified address to master.

```swift
import Suv
import Slimane

if Cluster.isMaster {
   let cluster = Cluster(Process.arguments)

   for i in 0..<OS.cpuCount {
       let worker = try! cluster.fork(silent: false)
   }

   // Need to bind address and listen server on parent
   try! Slimane().listen(host: "0.0.0.0", port: 3000)

} else {
  let app = Slimane()

  app.get("/") { req, res in
    res.write("Hello! I'm a \(Process.pid)")
  }

   // Not need bind, cause child processes use parent established connection with IPC.
  try! app.listen()
}
```


## Error Handling
We have a couple of error notification styles.

### Synchronous style
```swift
struct SomeValidator: MiddlewareType {
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws {

        if(someValidation(req)) {
          throw CustomErrorType("Validation Error")
        }

        next(nil)
    }
}
```

### Asynchronous style
Our Server is based on libuv, So if you wanna take data through I/O and Network, We should use non blocking Api to take that. Anyway it means need to use Callback, Event Emitter and Promise etc...

#### Throw(Recommended)
```swift
struct StaticFileServe: MiddlewareType {
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws {
        File.read("/public/foo/bar.jpg") { err, image throws in
          if(err) {
            throw err
          }

          res.setHeader("Content-Type", "image/jpeg")
          res.write(image)
        }
    }
}
```

#### Pass the error to next callback
If the I/O library doesn't support `throw`, you can pass the error to next callback. and it means to go to ErrorHandler.handle even the middleware chain isn't reached at the last.

```swift
struct StaticFileServe: MiddlewareType {
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws {
        File.read("/public/foo/bar.jpg") { err, image in
          if(err) {
            return next(err)
          }

          res.setHeader("Content-Type", "image/jpeg")
          res.write(image)
        }
    }
}
```

### Error Handler
You can overwrite default error handler.  
All of the errors which are thrown in routes and middlewares will be came here.

```swift
struct MyErrorHandler: ErrorHandler {
  func handle(req req: Request, res: Response, error: ErrorType) {
    switch(error) {
    case Error.RouteNotFound:
        res.status(.NotFound).write("path is not found")

    case CustomeErrorType(let err):
        res.status(.BadRequest).write(err.description)

    default:
        res.status(.BadRequest).write("Unhandled error was encountered")
  }
}

// Overwrite default errorHandler
app.errorHandler = MyErrorHandler()
```



## Package.swift

```swift
import PackageDescription

let package = Package(
    name: "MyApp",
          dependencies: [
              .Package(url: "https://github.com/noppoMan/Slimane.git", majorVersion: 0, minor: 1),
          ]
 )
```

## License

(The MIT License)

Copyright (c) 2016 Yuki Takei(Noppoman) yuki@miketokyo.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and marthis permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
