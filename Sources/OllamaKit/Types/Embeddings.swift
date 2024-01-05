import Foundation
import SharedKit

public struct EmbeddingRequest: Codable {
    public var model: String
    public var prompt: String
    public var options: [String: AnyValue]
    
    public init(model: String, prompt: String, options: [String : AnyValue]) {
        self.model = model
        self.prompt = prompt
        self.options = options
    }
}

public struct EmbeddingResponse: Codable {
    public let embedding: [Float64]
}
