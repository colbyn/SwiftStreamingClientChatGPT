//
//  ChatGPT.swift
//  
//
//  Created by Colbyn Wadman on 12/23/23.
//

import Foundation

public struct ChatGPT {
    public struct Configuration {
        /// ID of the model to use.
        public var model: String = "gpt-3.5-turbo"
        /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
        /// while lower values like 0.2 will make it more focused and deterministic.
        public var temperature: Double? = nil
        /// How many chat completion choices to generate for each input message.
        public var n: Int? = nil
        /// The maximum number of tokens allowed for the generated answer. By default, the number of tokens the model can
        /// return will be (4096 - prompt tokens).
        public var maxTokens: Int? = nil
        /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of
        /// the tokens with `topP` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass
        /// are considered.
        public var topP: Double? = nil
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text
        /// so far, decreasing the model's likelihood to repeat the same line verbatim.
        public var frequencyPenalty: Double? = nil
        /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so
        /// far, increasing the model's likelihood to talk about new topics.
        public var presencePenalty: Double? = nil
        /// Include the log probabilities on the `logprobs` most likely tokens, as well the chosen tokens.
        ///
        /// For example, if `logprobs` is 5, the API will return a list of the 5 most likely tokens.
        /// The API will always return the `logprob` of the sampled token, so there may be up to
        /// `logprobs+1` elements in the response. The maximum value for `logprobs` is 5.
        public var logprobs: Int? = nil
        /// An object specifying the format that the model must output.
        /// Setting to `ChatCompletionsRequest.ResponseFormat.json` enables JSON mode, which guarantees the message the
        ///  model generates is valid JSON.
        ///
        /// **Important:** when using JSON mode, you must also instruct the model to produce JSON yourself via a system or
        /// user message. Without this, the model may generate an unending stream of whitespace until the generation reaches
        /// the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content
        /// may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the
        /// conversation exceeded the max context length.
        public var responseFormat: ResponseFormat?
        /// Up to 4 sequences where the API will stop generating further tokens.
        ///
        /// The returned text will not contain the stop sequence.
        public var stop: [String]? = nil
        public struct ResponseFormat: Codable {
            fileprivate var type: FormatType?
            fileprivate enum FormatType: String, Codable {
                case text = "text", jsonObject = "json_object"
            }
            public static let json = ResponseFormat(type: .jsonObject)
            public static let text = ResponseFormat(type: .text)
        }
    }
    
    public struct Message: Encodable {
        let role: Role
        let content: String
        public enum Role: String, Codable {
            case user, assistant, system
        }
    }
    public struct CompletionChunk: Codable {
        let id: String
        let object: String
        let created: Int
        let model: String
        let systemFingerprint: String?
        let choices: [Choice]
        public struct Choice: Codable {
            let index: Int
            let delta: Delta
            let finishReason: String?
            public struct Delta: Codable {
                let content: String?
            }
        }
    }
}

extension ChatGPT.Message {
    public static func user(content: String) -> Self {
        Self(role: .user, content: content)
    }
    public static func assistant(content: String) -> Self {
        Self(role: .assistant, content: content)
    }
    public static func system(content: String) -> Self {
        Self(role: .system, content: content)
    }
}

extension ChatGPT.Configuration {
    /// ID of the model to use.
    public func with(model: String) -> Self {
        var copy = self
        copy.model = model
        return copy
    }
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random,
    /// while lower values like 0.2 will make it more focused and deterministic.
    public func with(temperature: Double? = nil) -> Self {
        var copy = self
        copy.temperature = temperature
        return copy
    }
    /// How many chat completion choices to generate for each input message.
    public func with(n: Int? = nil) -> Self {
        var copy = self
        copy.n = n
        return copy
    }
    /// The maximum number of tokens allowed for the generated answer. By default, the number of tokens the model can
    /// return will be (4096 - prompt tokens).
    public func with(maxTokens: Int? = nil) -> Self {
        var copy = self
        copy.maxTokens = maxTokens
        return copy
    }
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of
    /// the tokens with `topP` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass
    /// are considered.
    public func with(topP: Double? = nil) -> Self {
        var copy = self
        copy.topP = topP
        return copy
    }
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text
    /// so far, decreasing the model's likelihood to repeat the same line verbatim.
    public func with(frequencyPenalty: Double? = nil) -> Self {
        var copy = self
        copy.frequencyPenalty = frequencyPenalty
        return copy
    }
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so
    /// far, increasing the model's likelihood to talk about new topics.
    public func with(presencePenalty: Double? = nil) -> Self {
        var copy = self
        copy.presencePenalty = presencePenalty
        return copy
    }
    /// Include the log probabilities on the `logprobs` most likely tokens, as well the chosen tokens.
    ///
    /// For example, if `logprobs` is 5, the API will return a list of the 5 most likely tokens.
    /// The API will always return the `logprob` of the sampled token, so there may be up to
    /// `logprobs+1` elements in the response. The maximum value for `logprobs` is 5.
    public func with(logprobs: Int? = nil) -> Self {
        var copy = self
        copy.logprobs = logprobs
        return copy
    }
    /// An object specifying the format that the model must output.
    /// Setting to `ChatCompletionsRequest.ResponseFormat.json` enables JSON mode, which guarantees the message the
    ///  model generates is valid JSON.
    ///
    /// **Important:** when using JSON mode, you must also instruct the model to produce JSON yourself via a system or
    /// user message. Without this, the model may generate an unending stream of whitespace until the generation reaches
    /// the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content
    /// may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the
    /// conversation exceeded the max context length.
    public func with(responseFormat: ResponseFormat?) -> Self {
        var copy = self
        copy.responseFormat = responseFormat
        return copy
    }
    /// Up to 4 sequences where the API will stop generating further tokens.
    ///
    /// The returned text will not contain the stop sequence.
    public func with(stop: [String]? = nil) -> Self {
        var copy = self
        copy.stop = stop
        return copy
    }
}

