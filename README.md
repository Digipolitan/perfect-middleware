DGPerfectMiddleware
=================================

[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

Perfect middleware swift allows developer to register middlewares inside a Perfect HTTPServer

## Installation

### Swift Package Manager

To install DGPerfectMiddleware with SPM, add the following lines to your `Package.swift`.

```swift
import PackageDescription

let package = Package(
    name: "XXX",
    dependencies: [
        .Package(url: "https://github.com/Digipolitan/perfect-middleware-swift.git", majorVersion: 1, minor: 0)
    ]
)
```

## The Basics

Create an HTTPServer and register routes in the RouterMiddleware

```swift
let server = HTTPServer()

let router = RouterMiddleware()

router.get(path: "/") { (context) in
    context.response.setBody(string: "It Works !").completed()
    context.next()
}

server.use(router: router)

server.serverPort = 8887

do {
    try server.start()
    print("Server listening on port \(server.serverPort)")
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```

Passing data between middlewares, you can provide 2 or more middleware for the same route and shared data across each middleware using the context

```swift
router.get(path: "/") { (context) in
    context["name"] = "Steve"
    context.next()
}

router.get(path: "/") { (context) in
    guard let name = context["name"] as? String else {
        return
    }
    context.response.setBody(string: "hello mr. \(name)!").completed()
    context.next()
}
```

It's possible to create and register Middleware subsclasses instead of closures

```swift
class RandomMiddleware: Middleware {

    func handle(context: RouteContext) throws {
        context["rand"] = arc4random()
        context.next()
    }
}
```

Register Middleware as follow :

```swift
router.post(path: "/random", middleware: RandomMiddleware())

router.post(path: "/random") { (context) in
    guard let rand = context["rand"] as? UInt32 else {
        return
    }
    context.response.setBody(string: "the result \(rand)").completed()
    context.next()
}
```

## Advanced

### Register middleware for all routes

it's possible to register middlewares before & after all child routes of the router

router.use(event: .beforeAll) { (context) in
    context["start_date"] = Date()
    context.next()
}.use(event: .afterAll) { (context) in
    guard let startDate = context["start_date"] as? Date else {
        return
    }
    let duration = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
    print(String(duration * 1000) + " ms")
    context.next()
}

This code will print the duration in second of the process for each route

### 404 handler

router.use(event: .notFound) { (context) in
    context.response.setBody(string: "404").completed()
    context.next()
}

### Error handler

router.use { (err, context) in
    context.response.setBody(string: err.localizedDescription).completed()
    context.next()
}

### Register sub routers

This code print "My name is" by calling "/user/name" path in your server

```swift
let router = RouterMiddleware()

let childRouter = RouterMiddleware()

childRouter.get(path: "/name") { (context) in
    context.response.setBody(string: "My name is").completed()
    context.next()
}

router.use(path: "/user", router: childRouter)

server.use(router: router)
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

DGPerfectMiddleware is licensed under the [BSD 3-Clause license](LICENSE).
