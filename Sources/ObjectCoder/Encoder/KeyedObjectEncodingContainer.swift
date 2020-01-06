import Foundation

internal class KeyedObjectEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private let encoder: ObjectEncoder
    private let container: DictionaryContainer
    private var nestedContainers: [String: ObjectContainer] = [:]
    private let completion: (_ object: Any) -> Void
    
    let codingPath: [CodingKey]
    
    init(referencing encoder: ObjectEncoder,
         codingPath: [CodingKey], container: DictionaryContainer,
         completion: @escaping (_ object: Any) -> Void = { _ in }) {
        
        self.encoder = encoder
        self.container = container
        self.completion = completion
        self.codingPath = codingPath
    }
    
    deinit {
        completion(container.object)
    }
    
    func encode(_ value: Bool, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Int, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Int8, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Int16, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Int32, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Int64, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: UInt, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: UInt8, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: UInt16, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: UInt32, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: UInt64, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Float, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: Double, forKey key: Key) throws { container.set(value, for: key) }
    func encode(_ value: String, forKey key: Key) throws { container.set(value, for: key) }
    
    func encodeNil(forKey key: Key) throws {
        container.set(encoder.nilEncodingStrategy.nilValue, for: key)
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        container.set(try encoder.box(value), for: key)
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        
        let keyedContainer = KeyedObjectEncodingContainer<NestedKey>(
            referencing: encoder,
            codingPath: codingPath + [key],
            container: dictionaryContainer(forKey: key),
            completion: { [container] in container.set($0, for: key) })
        return KeyedEncodingContainer(keyedContainer)
    }
    
    private func dictionaryContainer(forKey key: Key) -> DictionaryContainer {
        let containerKey = key.stringValue
        
        if let existingContainer = nestedContainers[containerKey] {
            if let result = existingContainer as? DictionaryContainer {
                return result
            }
            
            preconditionFailure("Attempt to re-encode into nested "
                + "KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: "
                + "non-keyed container already encoded for this key.")
        }
        
        let result = DictionaryContainer()
        nestedContainers[containerKey] = result
        return result
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return UnkeyedObjectEncodingContanier(
            referencing: encoder,
            codingPath: codingPath + [key],
            container: arrayContainer(forKey: key),
            completion: { [container] in container.set($0, for: key) })
    }
    
    private func arrayContainer(forKey key: Key) -> ArrayContainer {
        let containerKey = key.stringValue
        
        if let existingContainer = nestedContainers[containerKey] {
            if let result = existingContainer as? ArrayContainer {
                return result
            }
            
            preconditionFailure("Attempt to re-encode into nested "
                + "UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: "
                + "keyed container/single value already encoded for this key.")
        }
        
        let result = ArrayContainer()
        nestedContainers[containerKey] = result
        return result
    }
    
    func superEncoder() -> Encoder {
        return makeSuperEncoder(key: ObjectKey.superKey)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return makeSuperEncoder(key: key)
    }
    
    private func makeSuperEncoder(key: CodingKey) -> Encoder {
        return ReferencingEncoder(
            referenceCodingPath: codingPath,
            key: key,
            options: encoder.options,
            completion: { [container] in container.set($0, for: key) })
    }
}
