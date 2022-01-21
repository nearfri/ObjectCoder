import Foundation

// ref.: https://github.com/apple/swift-corelibs-foundation/blob/b878ee2c106d0883b2c1206aeffa61ca4a287c54/Darwin/Foundation-swiftoverlay/PlistEncoder.swift

public class ObjectDecoder: Decoder {
    public internal(set) var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var nilDecodingStrategy: NilDecodingStrategy = .default
    public var passthroughTypes: [Decodable.Type] = [Data.self, Date.self]
    
    internal let storage: DecodingStorage = DecodingStorage()
    
    public init() {
        self.codingPath = []
    }
    
    internal init(codingPath: [CodingKey], container: Any, options: Options) {
        self.codingPath = codingPath
        self.storage.pushContainer(container)
        
        self.userInfo = options.userInfo
        self.nilDecodingStrategy = options.nilDecodingStrategy
        self.passthroughTypes = options.passthroughTypes
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
            throw Errors.nilKeyedContainer(codingPath: codingPath, keyType: type)
            
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
            throw Errors.nilUnkeyedContainer(codingPath: codingPath)
            
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
    internal struct Options {
        var userInfo: [CodingUserInfoKey: Any] = [:]
        var nilDecodingStrategy: NilDecodingStrategy = .default
        var passthroughTypes: [Decodable.Type] = [Data.self, Date.self]
    }
    
    internal var options: Options {
        return Options(userInfo: userInfo,
                       nilDecodingStrategy: nilDecodingStrategy,
                       passthroughTypes: passthroughTypes)
    }
}
