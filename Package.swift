// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "PerfectMiddleware",
    products: [
        .library(
            name: "PerfectMiddleware",
            targets: ["PerfectMiddleware"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "PerfectMiddleware",
            dependencies: ["PerfectHTTPServer"]),
        .testTarget(
            name: "PerfectMiddlewareTests",
            dependencies: ["PerfectHTTPServer"])
    ]
)
