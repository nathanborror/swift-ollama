import Foundation
import SharedKit

public struct GenerateRequest: Codable {
    public var model: String
    public var prompt: String
    public var suffix: String?
    public var format: String?
    public var options: [String: AnyValue]?
    public var system: String?
    public var template: String?
    public var context: [Int]?
    public var stream: Bool
    public var raw: Bool?
    public var keepAlive: String?
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case suffix
        case format
        case options
        case system
        case template
        case context
        case stream
        case raw
        case keepAlive = "keep_alive"
    }
    
    public init(model: String, prompt: String, suffix: String? = nil, format: String? = nil,
                options: [String : AnyValue]? = nil, system: String? = nil, template: String? = nil,
                context: [Int]? = nil, stream: Bool = true, raw: Bool? = nil, keepAlive: String? = nil) {
        self.model = model
        self.prompt = prompt
        self.suffix = suffix
        self.format = format
        self.options = options
        self.system = system
        self.template = template
        self.context = context
        self.stream = stream
        self.raw = raw
        self.keepAlive = keepAlive
    }
}

public struct GenerateResponse: Codable {
    public let model: String
    public let createdAt: Date
    public let response: String
    
    public let done: Bool
    public let context: [Int]?
    
    public let totalDuration: Int?
    public let loadDuration: Int?
    public let promptEvalCount: Int?
    public let promptEvalDuration: Int?
    public let evalCount: Int?
    public let evalDuration: Int?
    
    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response
        case done
        case context
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}
