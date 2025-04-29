import Foundation
import JSONSchema

extension KeyedDecodingContainer {

    /// Convenience function to decode into a raw JSON string.
    public func decodeRawJSON(forKey key: K) throws -> String {
        let dict = try decodeIfPresent([String: JSONValue].self, forKey: key) ?? [:]
        let data = try JSONEncoder().encode(dict)
        guard let out = String(data: data, encoding: .utf8) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unable to decode JSON as a string.")
        }
        return out
    }
}

extension JSONDecoder.DateDecodingStrategy {

    public static let iso8601WithFractionalSeconds = custom { decoder -> Date in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
    }
}
