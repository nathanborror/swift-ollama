import Foundation

public final class Client {

    public static let defaultHost = URL(string: "http://127.0.0.1:8080/api")!

    public let host: URL

    internal(set) public var session: URLSession

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(session: URLSession = URLSession(configuration: .default), host: URL? = nil) {
        self.session = session
        self.host = host ?? Self.defaultHost
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        case requestError(String)
        case responseError(response: HTTPURLResponse, detail: String)
        case decodingError(response: HTTPURLResponse, detail: String)
        case unexpectedError(String)

        public var description: String {
            switch self {
            case .requestError(let detail):
                return "Request error: \(detail)"
            case .responseError(let response, let detail):
                return "Response error (Status \(response.statusCode)): \(detail)"
            case .decodingError(let response, let detail):
                return "Decoding error (Status \(response.statusCode)): \(detail)"
            case .unexpectedError(let detail):
                return "Unexpected error: \(detail)"
            }
        }
    }

    private enum Method: String {
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
    }

    struct ErrorResponse: Swift.Error, CustomStringConvertible, Decodable {
        let error: String

        public var description: String {
            "\(error)"
        }
    }
}

// MARK: - Completions

extension Client {

    public func generateCompletions(_ request: GenerateRequest) async throws -> GenerateResponse {
        guard request.stream == false else {
            throw Error.requestError("ChatRequest.stream cannot be set to 'true'")
        }
        return try await fetch(.post, "generate", body: request)
    }

    public func generateCompletionsStream(_ request: GenerateRequest) throws -> AsyncThrowingStream<GenerateResponse, Swift.Error> {
        print(request.stream)
        guard request.stream == true else {
            throw Error.requestError("ChatRequest.stream must be set to 'true'")
        }
        return try fetchAsync(.post, "generate", body: request)
    }
}

// MARK: - Chats

extension Client {

    public func chatCompletions(_ request: ChatRequest) async throws -> ChatResponse {
        guard request.stream != nil || request.stream == true else {
            throw Error.requestError("ChatRequest.stream must be set to 'false'")
        }
        return try await fetch(.post, "chat", body: request)
    }

    public func chatCompletionsStream(_ request: ChatRequest) throws -> AsyncThrowingStream<ChatResponse, Swift.Error> {
        guard request.stream == nil || request.stream == true else {
            throw Error.requestError("ChatRequest.stream must be set to 'true' or nil")
        }
        return try fetchAsync(.post, "chat", body: request)
    }
}

// MARK: - Models

extension Client {

    public func models() async throws -> ModelsResponse {
        try await fetch(.get, "tags")
    }

    public func model(_ request: ModelShowRequest) async throws -> ModelShowResponse {
        try await fetch(.post, "show", body: request)
    }

    public func modelCopy(_ request: ModelCopyRequest) async throws {
        let _: EmptyResponse = try await fetch(.post, "copy", body: request)
    }

    public func modelDelete(_ request: ModelDeleteRequest) async throws {
        let _: EmptyResponse = try await fetch(.delete, "delete", body: request)
    }

    public func modelPull(_ request: ModelPullRequest) throws -> AsyncThrowingStream<ProgressResponse, Swift.Error> {
        guard request.stream == true else {
            throw Error.requestError("ModelPullRequest.stream must be set to 'true'")
        }
        return try fetchAsync(.post, "pull", body: request)
    }

    public func modelPush(_ request: ModelPushRequest) throws -> AsyncThrowingStream<ProgressResponse, Swift.Error> {
        guard request.stream == true else {
            throw Error.requestError("ModelPullRequest.stream must be set to 'true'")
        }
        return try fetchAsync(.post, "push", body: request)
    }
}

// MARK: - Embeddings

extension Client {

    public func embeddings(_ request: EmbeddingsRequest) async throws -> EmbeddingsResponse {
        try await fetch(.post, "embeddings", body: request)
    }
}

extension Client {

    private func fetch<Response: Decodable>(_ method: Method, _ path: String, body: Encodable? = nil) async throws -> Response {
        let request = try makeRequest(path: path, method: method, body: body)
        let (data, resp) = try await session.data(for: request)
        try checkResponse(resp, data)
        return try decoder.decode(Response.self, from: data)
    }

    private func fetchAsync<Response: Codable>(_ method: Method, _ path: String, body: Encodable) throws -> AsyncThrowingStream<Response, Swift.Error> {
        let request = try makeRequest(path: path, method: method, body: body)
        return AsyncThrowingStream { continuation in
            let session = StreamingSession<Response>(session: session, request: request)
            session.onReceiveContent = {_, object in
                continuation.yield(object)
            }
            session.onProcessingError = {_, error in
                continuation.finish(throwing: error)
            }
            session.onComplete = { object, error in
                continuation.finish(throwing: error)
            }
            session.perform()
        }
    }

    private func checkResponse(_ resp: URLResponse?, _ data: Data) throws {
        if let response = resp as? HTTPURLResponse, response.statusCode != 200 {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw Error.responseError(response: response, detail: err.error)
            } else {
                throw Error.responseError(response: response, detail: "Unknown response error")
            }
        }
    }

    private func makeRequest(path: String, method: Method, body: Encodable? = nil) throws -> URLRequest {
        var req = URLRequest(url: host.appending(path: path))
        req.httpMethod = method.rawValue
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if let body {
            req.httpBody = try encoder.encode(body)
        }
        return req
    }
}

private struct EmptyResponse: Decodable {}
