import Foundation

internal struct UnkeyedObjectDecodingContainer: UnkeyedDecodingContainer {
    private let decoder: ObjectDecoder
    private let container: [Any]
    
    let codingPath: [CodingKey]
    
    private(set) var currentIndex: Int
    
    var count: Int? {
        return container.count
    }
    
    var isAtEnd: Bool {
        return currentIndex >= count!
    }
    
    init(referencing decoder: ObjectDecoder, codingPath: [CodingKey], container: [Any]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = codingPath
        self.currentIndex = 0
    }
    
    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw makeEndOfContainerError(expectation: Any?.self)
        }
        
        let value = container[currentIndex]
        if decoder.nilDecodingStrategy.isNilValue(value) {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        return try decodeValue(type: type)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        return try decodeValue(type: type)
    }
    
    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        guard !isAtEnd else {
            throw makeEndOfContainerError(expectation: type)
        }
        
        decoder.codingPath.append(ObjectKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        let value = container[currentIndex]
        let decodedValue = try decoder.unbox(value, as: type)
        currentIndex += 1
        
        return decodedValue
    }
    
    private func makeEndOfContainerError(expectation: Any.Type) -> DecodingError {
        let currentCodingPath = codingPath + [ObjectKey(index: currentIndex)]
        let context = DecodingError.Context(codingPath: currentCodingPath,
                                            debugDescription: "Unkeyed container is at end.")
        return DecodingError.valueNotFound(expectation, context)
    }
    
    private mutating func decodeValue<T: InitializableWithAny>(type: T.Type) throws -> T {
        guard !isAtEnd else {
            throw makeEndOfContainerError(expectation: type)
        }
        
        let key = ObjectKey(index: currentIndex)
        let value = container[currentIndex]
        if decoder.nilDecodingStrategy.isNilValue(value) {
            throw Errors.valueNotFound(codingPath: codingPath + [key], expectation: type)
        }
        
        let decodedValue = try type.init(value: value, codingPath: codingPath + [key])
        currentIndex += 1
        
        return decodedValue
    }
    
    mutating func nestedContainer<NestedKey: CodingKey >(
        keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        
        let nestedCodingPath = codingPath + [ObjectKey(index: currentIndex)]
        
        guard !isAtEnd else {
            throw UnkeyedContainerErrors.nestedContainerNotFound(
                codingPath: nestedCodingPath, keyType: type)
        }
        
        let value = container[currentIndex]
        guard let dictionary = value as? [String: Any] else {
            throw Errors.typeMismatch(codingPath: nestedCodingPath,
                                      expectation: [String: Any].self, reality: value)
        }
        
        currentIndex += 1
        
        let keyedContainer = KeyedObjectDecodingContainer<NestedKey>(
            referencing: decoder, codingPath: nestedCodingPath, container: dictionary)
        return KeyedDecodingContainer(keyedContainer)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let nestedCodingPath = codingPath + [ObjectKey(index: currentIndex)]
        
        guard !isAtEnd else {
            throw UnkeyedContainerErrors.nestedUnkeyedContainerNotFound(
                codingPath: nestedCodingPath)
        }
        
        let value = container[currentIndex]
        guard let array = value as? [Any] else {
            throw Errors.typeMismatch(codingPath: nestedCodingPath,
                                      expectation: [Any].self, reality: value)
        }
        
        currentIndex += 1
        
        return UnkeyedObjectDecodingContainer(
            referencing: decoder, codingPath: nestedCodingPath, container: array)
    }
    
    mutating func superDecoder() throws -> Decoder {
        let superCodingPath = codingPath + [ObjectKey(index: currentIndex)]
        
        guard !isAtEnd else {
            throw UnkeyedContainerErrors.superDecoderNotFound(codingPath: superCodingPath)
        }
        
        let value = container[currentIndex]
        
        currentIndex += 1
        
        return ObjectDecoder(codingPath: superCodingPath,
                             container: value,
                             options: decoder.options)
    }
}
