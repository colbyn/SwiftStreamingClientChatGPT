#  StreamingClientChatGPT

Add this to your `dependencies` like so, 
```swift
dependencies: [
    .package(url: "https://github.com/colbyn/SwiftStreamingClientChatGPT", from: "0.1.0")
]
```

Then for your given target,
```swift
targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
        name: "MyApp",
        dependencies: [ .product(name: "StreamingClientChatGPT", package: "SwiftStreamingClientChatGPT") ]
    ),
]
```
