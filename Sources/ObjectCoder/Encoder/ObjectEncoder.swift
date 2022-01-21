import Foundation

// ref.: https://github.com/apple/swift-corelibs-foundation/blob/b878ee2c106d0883b2c1206aeffa61ca4a287c54/Darwin/Foundation-swiftoverlay/PlistEncoder.swift

public class ObjectEncoder {
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var nilEncodingStrategy: NilEncodingStrategy = .default
    public var passthroughTypes: [Encodable.Type] = [Data.self, Date.self]
    
    public init() {}
    
    public func encode<T: Encodable>(_ value: T) throws -> Any {
        let encoder = ObjectEncoderInternal()
        
        encoder.userInfo = userInfo
        encoder.nilEncodingStrategy = nilEncodingStrategy
        encoder.passthroughTypes = passthroughTypes
        
        return try encoder.encode(value)
    }
}

class ObjectEncoderInternal: Encoder {
    public internal(set) var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var nilEncodingStrategy: NilEncodingStrategy = .default
    public var passthroughTypes: [Encodable.Type] = [Data.self, Date.self]
    
    internal let storage: EncodingStorage = EncodingStorage()
    
    public init() {
        self.codingPath = []
    }
    
    internal init(codingPath: [CodingKey], options: Options) {
        self.codingPath = codingPath
        
        self.userInfo = options.userInfo
        self.nilEncodingStrategy = options.nilEncodingStrategy
        self.passthroughTypes = options.passthroughTypes
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Any {
        defer { cleanup() }
        return try boxTopLevel(value)
    }
    
    public func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        if canEncodeNewValue {
            storage.pushContainer(DictionaryContainer())
        }
        
        guard let topContainer = storage.topContainer as? DictionaryContainer else {
            preconditionFailure("Attempt to push new keyed encoding container "
                + "when already previously encoded at this path.")
        }
        
        let keyedContainer = KeyedObjectEncodingContainer<Key>(
            referencing: self, codingPath: codingPath, container: topContainer)
        
        return KeyedEncodingContainer(keyedContainer)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        if canEncodeNewValue {
            storage.pushContainer(ArrayContainer())
        }
        
        guard let topContainer = storage.topContainer as? ArrayContainer else {
            preconditionFailure("Attempt to push new unkeyed encoding container "
                + "when already previously encoded at this path.")
        }
        
        return UnkeyedObjectEncodingContanier(
            referencing: self, codingPath: codingPath, container: topContainer)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueObjectEncodingContanier(referencing: self, codingPath: codingPath)
    }
    
    internal var canEncodeNewValue: Bool {
        return storage.count == codingPath.count
    }
}

extension ObjectEncoderInternal {
    private func cleanup() {
        codingPath.removeAll()
        storage.removeAll()
    }
    
    private func boxTopLevel<T: Encodable>(_ value: T) throws -> Any {
        if isPassthroughType(T.self) {
            return value
        }
        let throwError = { throw Errors.topLevelDidNotEncode(topLevel: value) }
        return try boxValue(value, whenNoResult: throwError)
    }
    
    internal func box<T: Encodable>(_ value: T) throws -> Any {
        if isPassthroughType(T.self) {
            return value
        }
        let returnEmptyDictionary = { [:] as [String: Any] }
        return try boxValue(value, whenNoResult: returnEmptyDictionary)
    }
    
    private func isPassthroughType(_ type: Encodable.Type) -> Bool {
        return passthroughTypes.contains(where: { type == $0 })
    }
    
    private func boxValue<T: Encodable>(_ value: T, whenNoResult: () throws -> Any) throws -> Any {
        let depth = storage.count
        do {
            try value.encode(to: self)
        } catch {
            if storage.count > depth {
                storage.popContainer()
            }
            throw error
        }
        
        guard storage.count > depth else {
            return try whenNoResult()
        }
        return storage.popContainer().object
    }
}

extension ObjectEncoderInternal {
    internal struct Options {
        var userInfo: [CodingUserInfoKey: Any]
        var nilEncodingStrategy: NilEncodingStrategy
        var passthroughTypes: [Encodable.Type]
    }
    
    internal var options: Options {
        return Options(userInfo: userInfo,
                       nilEncodingStrategy: nilEncodingStrategy,
                       passthroughTypes: passthroughTypes)
    }
}
