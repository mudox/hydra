import Foundation

protocol JSONDecodable: Decodable {
  static func jsonDecode(from: Data) -> Self
  static func jsonDecode(from: String) -> Self
}

protocol JSONEncodable: Encodable {
  var endcodedJSONData: Data { get }
  var endcodedJSONString: String { get }
}

extension JSONDecodable {
  /// Returns an instance by decoding the data argument
  ///
  /// - Parameter string: string
  /// - Returns: The decoded instance
  /// - Throws: Swift.DecodingError
  static func jsonDecode(from data: Data) throws -> Self {
    return try JSONDecoder().decode(Self.self, from: data)
  }

  /// Returns an instance by decoding the JSON string, using .utf8
  /// to encode String argumetn into Data
  ///
  /// - Parameter string: string
  /// - Returns: The decoded instance
  /// - Throws: `Swift.DecodingError`
  static func jsonDecode(from string: String) throws -> Self {
    let data = string.data(using: .utf8)!
    return try JSONDecoder().decode(Self.self, from: data)
  }
}

extension Encodable {
  var jsonData: Data? {
    return try? JSONEncoder().encode(self)
  }

  var jsonString: String? {
    guard let data = self.jsonData else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
