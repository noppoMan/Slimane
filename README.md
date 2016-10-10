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

## Getting Started
[Installation Guide](https://github.com/noppoMan/Slimane/wiki)

## Documentation
[Documentation Page is here](https://github.com/noppoMan/Slimane/wiki)

## License

Slimane is released under the MIT license. See LICENSE for details.
