import Foundation

public struct ModelListResponse: Codable {
    public let models: [ModelResponse]
}

public struct ModelResponse: Codable {
    public let name: String
    public let model: String
    public let modified: Date
    public let size: Int64
    public let digest: String
    public let details: Details?
    
    public struct Details: Codable {
        public let parent: String?
        public let format: String
        public let family: String
        public let families: [String]?
        public let parameterSize: String
        public let quantizationLevel: String
        
        enum CodingKeys: String, CodingKey {
            case parent = "parent_model"
            case format
            case family
            case families
            case parameterSize = "parameter_size"
            case quantizationLevel = "quantization_level"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case model
        case modified = "modified_at"
        case size
        case digest
        case details
    }
}

public struct ModelShowRequest: Codable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct ModelShowResponse: Codable {
    public let license: String?
    public let modelfile: String?
    public let parameters: String?
    public let template: String?
    public let system: String?
}

public struct ModelCreateRequest: Codable {
    public var name: String
    public var path: String
    public var stream: Bool?
    
    public init(name: String, path: String, stream: Bool? = nil) {
        self.name = name
        self.path = path
        self.stream = stream
    }
}

public struct ModelDeleteRequest: Codable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct ModelCopyRequest: Codable {
    public var source: String
    public var destination: String
    
    public init(source: String, destination: String) {
        self.source = source
        self.destination = destination
    }
}

public struct ModelPullRequest: Codable {
    public var name: String
    public var insecure: Bool?
    public var username: String?
    public var password: String?
    public var stream: Bool?
    
    public init(name: String, insecure: Bool? = nil, username: String? = nil, password: String? = nil, stream: Bool? = nil) {
        self.name = name
        self.insecure = insecure
        self.username = username
        self.password = password
        self.stream = stream
    }
}

public struct ModelPushRequest: Codable {
    public var name: String
    public var insecure: Bool?
    public var username: String
    public var password: String
    public var stream: Bool?
    
    public init(name: String, insecure: Bool? = nil, username: String, password: String, stream: Bool? = nil) {
        self.name = name
        self.insecure = insecure
        self.username = username
        self.password = password
        self.stream = stream
    }
}

public struct ProgressResponse: Codable {
    public let status: String
    public let digest: String?
    public let total: Int64?
    public let completed: Int64?
}
