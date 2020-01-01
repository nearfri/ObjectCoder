import Foundation

// ref.: https://github.com/apple/swift/blob/master/stdlib/public/Darwin/Foundation/PlistEncoder.swift

public class ObjectDecoder: Decoder {
    public internal(set) var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var nilDecodingStrategy: NilDecodingStrategy = .default
    public var passthroughTypes: [Decodable.Type] = [Data.self, Date.self]
    
    internal let storage: DecodingStorage = DecodingStorage()
    
    public init() {
        self.codingPath = []
    }
    
    internal init(codingPath: [CodingKey], container: Any) {
        self.codingPath = codingPath
        self.storage.pushContainer(container)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        defer { cleanup() }
        return try unbox(value, as: type)
    }
    
    public func container<Key: CodingKey>(
        keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        
        switch storage.topContainer {
        case let topContainer as [String: Any]:
            let decodingContainer = KeyedObjectDecodingContainer<Key>(
                referencing: self, codingPath: codingPath, container: topContainer)
            return KeyedDecodingContainer(decodingContainer)
            
        case let topContainer where nilDecodingStrategy.isNilValue(topContainer):
            let desc = "Cannot get keyed decoding container -- found nil value instead."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self, context)
            
        default:
            throw Errors.typeMismatch(codingPath: codingPath,
                                      expectation: [String: Any].self,
                                      reality: storage.topContainer)
        }
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch storage.topContainer {
        case let topContainer as [Any]:
            return UnkeyedObjectDecodingContainer(
                referencing: self, codingPath: codingPath, container: topContainer)
            
        case let topContainer where nilDecodingStrategy.isNilValue(topContainer):
            let desc = "Cannot get unkeyed decoding container -- found nil value instead."
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
            
        default:
            throw Errors.typeMismatch(codingPath: codingPath,
                                      expectation: [Any].self,
                                      reality: storage.topContainer)
        }
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueObjectDecodingContainer(referencing: self, codingPath: codingPath)
    }
}

extension ObjectDecoder {
    private func cleanup() {
        codingPath.removeAll()
        storage.removeAll()
    }
    
    internal func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T {
        if let value = value as? T, isPassthroughType(type) {
            return value
        }
        
        storage.pushContainer(value)
        defer { storage.popContainer() }
        
        return try type.init(from: self)
    }
    
    private func isPassthroughType(_ type: Decodable.Type) -> Bool {
        return passthroughTypes.contains(where: { type == $0 })
    }
}

extension ObjectDecoder {
    // ObjectEncoder.encodeValue()와 마찬가지 이유로 type-erased 구현은 공개하지 않는다.
    private func decodeValue(of type: Decodable.Type, from object: Any) throws -> Any {
        defer { cleanup() }
        
        if Swift.type(of: object) == type, isPassthroughType(type) {
            return object
        }
        
        storage.pushContainer(object)
        defer { storage.popContainer() }
        
        return try type.init(from: self)
    }
}
