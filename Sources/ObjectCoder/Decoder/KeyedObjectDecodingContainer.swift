import Foundation

internal struct KeyedObjectDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    private let decoder: ObjectDecoder
    private let container: [String: Any]
    
    let codingPath: [CodingKey]
    
    var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0) }
    }
    
    init(referencing decoder: ObjectDecoder,
         codingPath: [CodingKey], container: [String: Any]) {
        
        self.decoder = decoder
        self.container = container
        self.codingPath = codingPath
    }
    
    func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let value = try self.value(forKey: key)
        return decoder.nilDecodingStrategy.isNilValue(value)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try decodeValue(type: type, forKey: key)
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let value = try self.value(forKey: key)
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        return try decoder.unbox(value, as: type)
    }
    
    private func value(forKey key: Key) throws -> Any {
        guard let result = container[key.stringValue] else {
            throw Errors.keyNotFound(codingPath: codingPath, key: key)
        }
        return result
    }
    
    private func decodeValue<T: InitializableWithAny>(
        type: T.Type, forKey key: Key) throws -> T {
        
        let value = try self.value(forKey: key)
        if decoder.nilDecodingStrategy.isNilValue(value) {
            throw Errors.valueNotFound(codingPath: codingPath + [key], expectation: type)
        }
        
        return try type.init(value: value, codingPath: codingPath + [key])
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        
        let nestedCodingPath = codingPath + [key]
        
        guard let value = container[key.stringValue] else {
            throw KeyedContainerErrors.nestedContainerNotFound(
                codingPath: nestedCodingPath, key: key, keyType: type)
        }
        
        guard let dictionary = value as? [String: Any] else {
            throw Errors.typeMismatch(codingPath: nestedCodingPath,
                                      expectation: [String: Any].self, reality: value)
        }
        
        let keyedContainer = KeyedObjectDecodingContainer<NestedKey>(
            referencing: decoder, codingPath: nestedCodingPath, container: dictionary)
        return KeyedDecodingContainer(keyedContainer)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let nestedCodingPath = codingPath + [key]
        
        guard let value = container[key.stringValue] else {
            throw KeyedContainerErrors.nestedUnkeyedContainerNotFound(
                codingPath: nestedCodingPath, key: key)
        }
        
        guard let array = value as? [Any] else {
            throw Errors.typeMismatch(codingPath: nestedCodingPath,
                                      expectation: [Any].self, reality: value)
        }
        
        return UnkeyedObjectDecodingContainer(
            referencing: decoder, codingPath: nestedCodingPath, container: array)
    }
    
    func superDecoder() throws -> Decoder {
        return try makeSuperDecoder(key: ObjectKey.superKey)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try makeSuperDecoder(key: key)
    }
    
    private func makeSuperDecoder(key: CodingKey) throws -> Decoder {
        let superCodingPath = codingPath + [key]
        let value = container[key.stringValue] ?? decoder.nilDecodingStrategy.nilValue
        return ObjectDecoder(codingPath: superCodingPath,
                             container: value,
                             options: decoder.options)
    }
}
