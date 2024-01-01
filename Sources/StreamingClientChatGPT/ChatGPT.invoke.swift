//
//  ChatGPT.invoke.swift
//
//
//  Created by Colbyn Wadman on 12/23/23.
//

import Foundation
import Darwin
import UniformTypeIdentifiers

fileprivate class StreamingSession: NSObject, URLSessionDataDelegate {
    private var apiToken: String
    private var urlSession: URLSession!
    private var dataTask: URLSessionDataTask?
    private var outputs: [ ChatGPT.CompletionChunk ] = []
    private let logger: Optional<(String) -> ()>
    private var finishedSemaphore = DispatchSemaphore(value: 0)
    
    /// timeoutIntervalForRequest: Time in seconds.
    init(logger: @escaping (String) -> (), apiToken: String, timeoutIntervalForRequest: TimeInterval) {
        self.logger = logger
        self.apiToken = apiToken
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest // Time in seconds
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func connect(requestPayload: RequestPayload) -> [ ChatGPT.CompletionChunk ] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestPayload = try! encoder.encode(requestPayload)
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestPayload
        
        self.dataTask = urlSession.dataTask(with: request)
        finishedSemaphore = DispatchSemaphore(value: 0)
        self.dataTask?.resume()
        finishedSemaphore.wait()
        return outputs
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        processSSEData(
            data,
            onData: {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let data = $0.data(using: .utf8)!
                if let completionChunk = try? decoder.decode(ChatGPT.CompletionChunk.self, from: data) {
                    if let logger = self.logger, let string = completionChunk.choices.first?.delta.content {
                        logger(string)
                    }
                    self.outputs.append(completionChunk)
                    return
                }
            },
            onStreamClosed: {
                self.stop()
            }
        )
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, error.localizedDescription != "cancelled" {
            print("UNHANDELED ERROR", error)
//            fatalError("TODO")
        }
        self.stop()
    }
    
    func stop() {
        finishedSemaphore.signal()
        self.dataTask?.cancel()
    }
    
    fileprivate struct RequestPayload: Encodable {
        let model: String
        let stream: Bool = true
        let messages: [ ChatGPT.Message ]
        let temperature: Double?
        let n: Int?
        let maxTokens: Int?
        let topP: Double?
        let frequencyPenalty: Double?
        let presencePenalty: Double?
        let logprobs: Int?
        let responseFormat: ChatGPT.Configuration.ResponseFormat?
        let stop: [String]?
    }
}

fileprivate func processSSEData(_ data: Data, onData: @escaping (String) -> Void, onStreamClosed: @escaping () -> Void) {
    guard let string = String(data: data, encoding: .utf8) else {
        print("Unable to decode data to string")
        return
    }
    let events = string.components(separatedBy: "\n\n")
    for event in events {
        processEvent(event: event, onData: onData, onStreamClosed: onStreamClosed)
    }
}

fileprivate func processEvent(event: String, onData: @escaping (String) -> Void, onStreamClosed: @escaping () -> Void) {
    if event.hasPrefix("event: close") {
        onStreamClosed()
        return
    }
    if event.hasPrefix("data: ") {
        let dataContent = event.dropFirst("data: ".count)
        if dataContent == "[DONE]" {
            onStreamClosed()
            return
        }
        onData(String(dataContent))
    }
}

extension ChatGPT {
    public static func invoke(
        configuration: Configuration,
        messages: [Message],
        apiToken: String,
        logger: @escaping (String) -> (),
        /// timeoutIntervalForRequest: Time in seconds.
        timeoutIntervalForRequest: TimeInterval
    ) -> [ChatGPT.CompletionChunk] {
        let sseClient = StreamingSession(logger: logger, apiToken: apiToken, timeoutIntervalForRequest: timeoutIntervalForRequest)
        let requestPayload = StreamingSession.RequestPayload(
            model: configuration.model,
            messages: messages,
            temperature: configuration.temperature,
            n: configuration.n,
            maxTokens: configuration.maxTokens,
            topP: configuration.topP,
            frequencyPenalty: configuration.frequencyPenalty,
            presencePenalty: configuration.presencePenalty,
            logprobs: configuration.logprobs,
            responseFormat: configuration.responseFormat,
            stop: configuration.stop
        )
        return sseClient.connect(requestPayload: requestPayload)
    }
}

