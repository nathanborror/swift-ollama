import Foundation

extension KeyedDecodingContainer {

    /// Convenience function to decode into a raw JSON string.
    public func decodeRawJSON(forKey key: K) throws -> String {
        let data = try decodeIfPresent(Data.self, forKey: key) ?? Data()
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unable to decode JSON as a string.")
        }
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
