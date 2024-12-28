import Foundation
import SharedKit

public struct EmbeddingsRequest: Codable {
    public var model: String
    public var input: String
    public var truncate: Bool?
    public var options: [String: AnyValue]?
    public var keep_alive: Bool?

    public init(model: String, input: String, truncate: Bool? = nil, options: [String : AnyValue]? = nil,
                keep_alive: Bool? = nil) {
        self.model = model
        self.input = input
        self.truncate = truncate
        self.options = options
        self.keep_alive = keep_alive
    }
}

public struct EmbeddingsResponse: Codable {
    public let embedding: [Float64]
}
