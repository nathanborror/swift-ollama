import Foundation

public final class OllamaClient {
    
    public struct Configuration {
        public let host: URL
        
        init(host: URL = URL(string: "http://127.0.0.1:8080/api")!) {
            self.host = host
        }
    }
    
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    // Generate
    
    public func generate(_ payload: GenerateRequest) async throws -> GenerateResponse {
        var body = payload
        body.stream = false
        
        var req = makeRequest(path: "generate", method: "POST")
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(GenerateResponse.self, from: data)
    }
    
    public func generateStream(_ payload: GenerateRequest) -> AsyncThrowingStream<GenerateResponse, Error> {
        makeAsyncRequest(path: "generate", method: "POST", body: payload)
    }
    
    // Chats
    
    public func chat(_ payload: ChatRequest) async throws -> ChatResponse {
        var body = payload
        body.stream = false
        
        var req = makeRequest(path: "chat", method: "POST")
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ChatResponse.self, from: data)
    }
    
    public func chatStream(_ payload: ChatRequest) -> AsyncThrowingStream<ChatResponse, Error> {
        makeAsyncRequest(path: "chat", method: "POST", body: payload)
    }
    
    // Models
    
    public func models() async throws -> ModelListResponse {
        let req = makeRequest(path: "tags", method: "GET")
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ModelListResponse.self, from: data)
    }
    
    public func model(_ payload: ModelShowRequest) async throws -> ModelShowResponse {
        var req = makeRequest(path: "show", method: "POST")
        req.httpBody = try JSONEncoder().encode(payload)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(ModelShowResponse.self, from: data)
    }
    
    public func modelCopy(_ payload: ModelCopyRequest) async throws {
        var req = makeRequest(path: "copy", method: "POST")
        req.httpBody = try JSONEncoder().encode(payload)
        
        let (_, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return
    }
    
    public func modelDelete(_ payload: ModelDeleteRequest) async throws {
        var req = makeRequest(path: "delete", method: "DELETE")
        req.httpBody = try JSONEncoder().encode(payload)
        
        let (_, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return
    }
    
    public func modelPull(_ payload: ModelPullRequest) -> AsyncThrowingStream<ProgressResponse, Error> {
        var body = payload
        body.stream = true
        return makeAsyncRequest(path: "pull", method: "POST", body: body)
    }
    
    public func modelPush(_ payload: ModelPushRequest) -> AsyncThrowingStream<ProgressResponse, Error> {
        var body = payload
        body.stream = true
        return makeAsyncRequest(path: "push", method: "POST", body: body)
    }
    
    // Embeddings
    
    public func embeddings(_ payload: EmbeddingRequest) async throws -> EmbeddingResponse {
        var req = makeRequest(path: "embeddings", method: "POST")
        req.httpBody = try JSONEncoder().encode(payload)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(EmbeddingResponse.self, from: data)
    }
    
    // Private
    
    private func makeRequest(path: String, method: String) -> URLRequest {
        var req = URLRequest(url: configuration.host.appending(path: path))
        req.httpMethod = method
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    private func makeAsyncRequest<Body: Codable, Response: Codable>(path: String, method: String, body: Body) -> AsyncThrowingStream<Response, Error> {
        var request = makeRequest(path: path, method: method)
        request.httpBody = try? JSONEncoder().encode(body)
        
        return AsyncThrowingStream { continuation in
            let session = StreamingSession<Response>(urlRequest: request)
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
    
    private var decoder: JSONDecoder {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
