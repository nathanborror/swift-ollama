import Foundation
import SharedKit

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var tools: [Tool]?
    public var format: String?
    public var options: [String: AnyValue]?
    public var stream: Bool?
    public var keepAlive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case tools
        case format
        case options
        case stream
        case keepAlive = "keep_alive"
    }
    
    public init(model: String, messages: [Message], tools: [Tool]? = nil, format: String? = nil,
                options: [String : AnyValue]? = nil, stream: Bool? = nil, keepAlive: Bool? = nil) {
        self.model = model
        self.messages = messages
        self.tools = tools
        self.format = format
        self.options = options
        self.stream = stream
        self.keepAlive = keepAlive
    }
}

public struct ChatResponse: Codable {
    public let model: String
    public let createdAt: Date
    public let message: Message?
    public let done: Bool?
    
    public let totalDuration: Int?
    public let loadDuration: Int?
    public let promptEvalCount: Int?
    public let promptEvalDuration: Int?
    public let evalCount: Int?
    public let evalDuration: Int?
    
    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case message
        case done
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

public struct Message: Codable {
    public var role: Role
    public var content: String
    public var images: [Data]?
    public var toolCalls: [ToolCall]?
    
    public enum Role: String, Codable {
        case system, assistant, user, tool
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case images
        case toolCalls = "tool_calls"
    }
    
    public init(role: Role, content: String, images: [Data]? = nil, toolCalls: [ToolCall]? = nil) {
        self.role = role
        self.content = content
        self.images = images
        self.toolCalls = toolCalls
    }
}

public struct Tool: Codable {
    public var type: String
    public var function: Function
    
    public struct Function: Codable {
        public var name: String
        public var description: String
        public var parameters: JSONSchema
        
        public init(name: String, description: String, parameters: JSONSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
    
    public init(type: String, function: Function) {
        self.type = type
        self.function = function
    }
}

public struct ToolCall: Codable {
    public var function: Function
    
    public struct Function: Codable {
        public var name: String
        public var arguments: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case arguments
        }
        
        public init (name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            
            // Decode arguments as a raw JSON string
            if let jsonString = try? container.decodeRawJSON(forKey: .arguments) {
                arguments = jsonString
            } else {
                arguments = "{}" // Default empty JSON if decoding fails
            }
        }
    }
    
    public init(function: Function) {
        self.function = function
    }
}
