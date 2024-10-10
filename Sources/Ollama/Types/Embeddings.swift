import Foundation
import SharedKit

public struct EmbeddingRequest: Codable {
    public var model: String
    public var input: String
    public var truncate: Bool?
    public var options: [String: AnyValue]?
    public var keepAlive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model
        case input
        case truncate
        case options
        case keepAlive = "keep_alive"
    }
    
    public init(model: String, input: String, truncate: Bool? = nil, options: [String : AnyValue]? = nil,
                keepAlive: Bool? = nil) {
        self.model = model
        self.input = input
        self.truncate = truncate
        self.options = options
        self.keepAlive = keepAlive
    }
}

public struct EmbeddingResponse: Codable {
    public let embedding: [Float64]
}
