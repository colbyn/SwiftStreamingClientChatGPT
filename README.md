#  StreamingClientChatGPT

Add this to your `dependencies` like so, 
```swift
dependencies: [
    .package(url: "https://github.com/colbyn/SwiftStreamingClientChatGPT", from: "0.3.0")
]
```

Then for your given target,
```swift
targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "StreamingClientChatGPT", package: "SwiftStreamingClientChatGPT")
        ]
    ),
]
```

# Usage Example
```swift
import Foundation
import StreamingClientChatGPT
import Darwin

let logger: (String) -> () = { part in
    fputs("\(part)", stderr)
}
let configuration = ChatGPT.Configuration()
    .with(model: "gpt-3.5-turbo-1106")
    .with(topP: 0.1)
let messages: [ChatGPT.Message] = [
    .system(content: "You are a helpful assistant."),
    .user(content: "What is ChatGPT?")
]
let outputs = ChatGPT.invoke(
    configuration: configuration,
    messages: messages,
    apiToken: CHAT_GPT_API_KEY,
    logger: logger
)
fputs("\n", stderr)
let outputMessage = outputs
    .compactMap { $0.choices.first?.delta.content }
    .joined(separator: "")
print("DONE")
```
