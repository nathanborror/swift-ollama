import Foundation
import ArgumentParser
import Ollama
import SharedKit

@main
struct Command: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with the Ollama API.",
        version: "0.0.1",
        subcommands: [
            ModelList.self,
            ChatCompletion.self,
        ],
        defaultSubcommand: ModelList.self
    )
}

struct GlobalOptions: ParsableCommand {
    @Option(name: .shortAndLong, help: "Ollama host URL.")
    var host = "http://127.0.0.1:11434/api"

    @Option(name: .shortAndLong, help: "Model to use.")
    var model = "llama3.2:latest"

    @Option(name: .shortAndLong, help: "System prompt.")
    var systemPrompt: String?

    var system: String?

    mutating func validate() throws {
        system = try ValueReader(input: systemPrompt)?.value()
    }
}

struct ModelList: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "models",
        abstract: "Returns available models."
    )

    @OptionGroup
    var global: GlobalOptions

    func run() async throws {
        let client = Client(host: .init(string: global.host))
        let resp = try await client.models()
        let out = resp.models.map { $0.model }.joined(separator: "\n")
        print(out)
    }
}

struct ChatCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "chat-completion",
        abstract: "Completes a chat request."
    )

    @OptionGroup
    var global: GlobalOptions

    @Option(name: .long, help: "Stream chat output.")
    var stream: Bool = false

    func run() async throws {
        let client = Client(host: .init(string: global.host))
        var messages: [Message] = []

        write("\nUsing \(global.model)\n\n")

        // System prompt
        if let system = global.system {
            let message = Message(role: .system, content: system)
            messages.append(message)
            write("\nSystem Prompt:\n\(system)\n\n")
        }

        while true {
            write("> ")
            guard let input = readLine(), !input.isEmpty else {
                continue
            }
            if input.lowercased() == "exit" {
                write("Exiting...")
                break
            }

            // Input message
            let message = Message(role: .user, content: input)
            messages.append(message)

            // Input request
            let req = ChatRequest(
                model: global.model,
                messages: messages,
                stream: stream
            )

            // Handle response
            if stream {
                var text = ""
                for try await resp in try client.chatCompletionsStream(req) {
                    let delta = resp.message?.content ?? ""
                    text += delta
                    write(delta)
                }
                messages.append(.init(role: .assistant, content: text))
                newline()
            } else {
                let resp = try await client.chatCompletions(req)
                let text = resp.message?.content ?? ""
                messages.append(.init(role: .assistant, content: text))
                write(text); newline()
            }
        }
    }

    func write(_ text: String?) {
        if let text, let data = text.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }

    func newline() {
        write("\n")
    }
}

// Helpers

enum ValueReader {
    case direct(String)
    case file(URL)

    init?(input: String?) throws {
        guard let input else { return nil }
        if FileManager.default.fileExists(atPath: input) {
            let url = URL(fileURLWithPath: input)
            self = .file(url)
        } else {
            self = .direct(input)
        }
    }

    func value() throws -> String {
        switch self {
        case .direct(let value):
            return value
        case .file(let url):
            return try String(contentsOf: url, encoding: .utf8)
        }
    }
}
