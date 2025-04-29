import Foundation
import Testing

@testable import Ollama

@Suite("Parsing Tests")
struct ParsingTests {

    @Test("Tool response")
    func testToolResponse() async throws {
        let json = """
            {
              "model":"qwen3:32b",
              "created_at":"2025-04-29T22:13:03.677351Z",
              "message":{
                "role":"assistant",
                "content":"",
                "tool_calls":[
                  {
                    "function":{
                      "name":"web_search",
                      "arguments":{
                        "kind":"web",
                        "query":"latest apple rumors"
                      }
                    }
                  }
                ]
              },
              "done_reason":"stop",
              "done":true,
              "total_duration":20367108750,
              "load_duration":49818917,
              "prompt_eval_count":1100,
              "prompt_eval_duration":554356584,
              "eval_count":269,
              "eval_duration":19758806375
            }
            """
        let resp = try decoder.decode(ChatResponse.self, from: json.data(using: .utf8)!)
        #expect(resp.model == "qwen3:32b")
        #expect(resp.message?.tool_calls?.first?.function.name == "web_search")
        #expect(resp.message?.tool_calls?.first?.function.arguments == "{\"kind\":\"web\",\"query\":\"latest apple rumors\"}")
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }
}
