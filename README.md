#  StreamingClientChatGPT

Add this to your `dependencies` like so, 
```swift
dependencies: [
    .package(url: "https://github.com/colbyn/SwiftJsonDataModel.git", from: "0.1.0")
]
```

Then for your given target,
```swift
targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
        name: "MyApp",
        dependencies: [ .product(name: "JsonDataModel", package: "SwiftJsonDataModel") ]
    ),
]
```

# Example Parsing the ChatGPT API Response
```swift
import Foundation
import JsonDataModel
let source = """
{
  "model" : "gpt-3.5-turbo-0613",
  "created" : 1703285199,
  "system_fingerprint" : null,
  "id" : "chatcmpl-8YiZr7YraVUZYsmxBA5Lj9sjT3J0r",
  "usage" : {
    "prompt_tokens" : 23,
    "completion_tokens" : 9,
    "total_tokens" : 32
  },
  "choices" : [
    {
      "logprobs" : null,
      "message" : {
        "role" : "assistant",
        "content" : "Hello! How can I assist you today?"
      },
      "index" : 0,
      "finish_reason" : "stop"
    }
  ],
  "object" : "chat.completion"
}
"""
let json = try! JSON.Value.parse(source: source)
let choices = json["choices"]?.asArray ?? []
for choice in choices {
    print(choice.stringify())
}
```

