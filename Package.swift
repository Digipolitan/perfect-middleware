// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-05-03 18:32:34 +0000
import PackageDescription

let package = Package(
	name: "PerfectMiddleware",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "PerfectMiddleware", dependencies: ["PerfectHTTPServer"]),
        .testTarget(name: "PerfectMiddlewareTests", dependencies: ["PerfectMiddleware"])
	]
)
