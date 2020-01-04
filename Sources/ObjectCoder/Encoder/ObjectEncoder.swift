import Foundation

// ref.: https://github.com/apple/swift/blob/master/stdlib/public/Darwin/Foundation/PlistEncoder.swift

public class ObjectEncoder: Encoder {
    public internal(set) var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var nilEncodingStrategy: NilEncodingStrategy = .default
    public var passthroughTypes: [Encodable.Type] = [Data.self, Date.self]
    
    internal let storage: EncodingStorage = EncodingStorage()
    
    public init() {
        self.codingPath = []
    }
    
    internal init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
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

extension ObjectEncoder {
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
