import Foundation

internal class UnkeyedObjectEncodingContanier: UnkeyedEncodingContainer {
    private let encoder: ObjectEncoder
    private let container: ArrayContainer
    private let completion: (_ object: Any) -> Void
    
    let codingPath: [CodingKey]
    
    var count: Int {
        return container.count
    }
    
    init(referencing encoder: ObjectEncoder,
         codingPath: [CodingKey], container: ArrayContainer,
         completion: @escaping (_ object: Any) -> Void = { _ in }) {
        
        self.encoder = encoder
        self.container = container
        self.completion = completion
        self.codingPath = codingPath
    }
    
    deinit {
        completion(container.object)
    }
    
    func encode(_ value: Bool) throws { container.append(value) }
    func encode(_ value: Int) throws { container.append(value) }
    func encode(_ value: Int8) throws { container.append(value) }
    func encode(_ value: Int16) throws { container.append(value) }
    func encode(_ value: Int32) throws { container.append(value) }
    func encode(_ value: Int64) throws { container.append(value) }
    func encode(_ value: UInt) throws { container.append(value) }
    func encode(_ value: UInt8) throws { container.append(value) }
    func encode(_ value: UInt16) throws { container.append(value) }
    func encode(_ value: UInt32) throws { container.append(value) }
    func encode(_ value: UInt64) throws { container.append(value) }
    func encode(_ value: Float) throws { container.append(value) }
    func encode(_ value: Double) throws { container.append(value) }
    func encode(_ value: String) throws { container.append(value) }
    
    func encodeNil() throws { container.append(encoder.nilEncodingStrategy.nilValue) }
    
    func encode<T: Encodable>(_ value: T) throws {
        let encoderCodingPath = encoder.codingPath
        encoder.codingPath = codingPath + [ObjectKey(index: count)]
        defer { encoder.codingPath = encoderCodingPath }
        
        container.append(try encoder.box(value))
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        
        let index = count
        container.append([:] as [String: Any])
        
        let keyedContainer = KeyedObjectEncodingContainer<NestedKey>(
            referencing: encoder,
            codingPath: codingPath + [ObjectKey(index: index)],
            container: DictionaryContainer(),
            completion: { [container] in container.replace(at: index, with: $0) })
        return KeyedEncodingContainer(keyedContainer)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let index = count
        container.append([] as [Any])
        
        return UnkeyedObjectEncodingContanier(
            referencing: encoder,
            codingPath: codingPath + [ObjectKey(index: index)],
            container: ArrayContainer(),
            completion: { [container] in container.replace(at: index, with: $0) })
    }
    
    func superEncoder() -> Encoder {
        let index = count
        container.append("placeholder for superEncoder")
        
        return ReferencingEncoder(
            referenceCodingPath: codingPath,
            key: ObjectKey(index: index),
            options: encoder.options,
            completion: { [container] in container.replace(at: index, with: $0) })
    }
}
