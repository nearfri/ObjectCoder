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
        return try box(value)
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
    
    internal func box<T: Encodable>(_ value: T) throws -> Any {
        if isPassthroughType(T.self) {
            return value
        }
        return try boxValue(value)
    }
    
    private func isPassthroughType(_ type: Encodable.Type) -> Bool {
        return passthroughTypes.contains(where: { type == $0 })
    }
    
    private func boxValue(_ value: Encodable) throws -> Any {
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
            return [:] as [String: Any]
        }
        return storage.popContainer().object
    }
}

extension ObjectEncoder {
    // 아래와 같은 type-erased value 대신 위와 같은 concreate value를 제공하는 건 의도된 디자인이다.
    // 당장은 타입이 필요없더라도 언젠가는 디코딩을 해야만 할 수도 있고 그러기 위해선 다시 타입이 필요하기 때문이다.
    // 따라서 인코딩을 할 때 타입을 지우는 건 지양해야 한다.
    // https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/9
    private func encodeValue(_ value: Encodable) throws -> Any {
        defer { cleanup() }
        
        if isPassthroughType(type(of: value)) {
            return value
        }
        return try boxValue(value)
    }
}
