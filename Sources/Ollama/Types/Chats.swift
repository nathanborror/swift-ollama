import Foundation
import SharedKit

public struct ChatRequest: Codable {
    public var model: String
    public var messages: [Message]
    public var tools: [Tool]?
    public var format: String?
    public var options: [String: AnyValue]?
    public var stream: Bool?
    public var keep_alive: Bool?

    public init(model: String, messages: [Message], tools: [Tool]? = nil, format: String? = nil,
                options: [String : AnyValue]? = nil, stream: Bool? = nil, keep_alive: Bool? = nil) {
        self.model = model
        self.messages = messages
        self.tools = tools
        self.format = format
        self.options = options
        self.stream = stream
        self.keep_alive = keep_alive
    }
}

public struct ChatResponse: Codable {
    public let model: String
    public let created_at: Date
    public let message: Message?
    public let done: Bool?
    
    public let total_duration: Int?
    public let load_duration: Int?
    public let prompt_eval_count: Int?
    public let prompt_eval_duration: Int?
    public let eval_count: Int?
    public let eval_duration: Int?
}

public struct Message: Codable {
    public var role: Role
    public var content: String
    public var images: [Data]?
    public var tool_calls: [ToolCall]?

    public enum Role: String, Codable {
        case system, assistant, user, tool
    }

    public init(role: Role, content: String, images: [Data]? = nil, tool_calls: [ToolCall]? = nil) {
        self.role = role
        self.content = content
        self.images = images
        self.tool_calls = tool_calls
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
