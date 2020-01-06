import Foundation

internal class SingleValueObjectEncodingContanier: SingleValueEncodingContainer {
    private let encoder: ObjectEncoder
    
    let codingPath: [CodingKey]
    
    init(referencing encoder: ObjectEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    func encode(_ value: Bool) throws { pushContainer(with: value) }
    func encode(_ value: Int) throws { pushContainer(with: value) }
    func encode(_ value: Int8) throws { pushContainer(with: value) }
    func encode(_ value: Int16) throws { pushContainer(with: value) }
    func encode(_ value: Int32) throws { pushContainer(with: value) }
    func encode(_ value: Int64) throws { pushContainer(with: value) }
    func encode(_ value: UInt) throws { pushContainer(with: value) }
    func encode(_ value: UInt8) throws { pushContainer(with: value) }
    func encode(_ value: UInt16) throws { pushContainer(with: value) }
    func encode(_ value: UInt32) throws { pushContainer(with: value) }
    func encode(_ value: UInt64) throws { pushContainer(with: value) }
    func encode(_ value: Float) throws { pushContainer(with: value) }
    func encode(_ value: Double) throws { pushContainer(with: value) }
    func encode(_ value: String) throws { pushContainer(with: value) }
    func encodeNil() throws { pushContainer(with: encoder.nilEncodingStrategy.nilValue) }
    func encode<T: Encodable>(_ value: T) throws {
        pushContainer(with: try encoder.box(value))
    }

    private func pushContainer(with value: Any, file: StaticString = #file, line: UInt = #line) {
        assertCanEncodeNewValue(file: file, line: line)
        encoder.storage.pushContainer(AnyContainer(object: value))
    }
    
    private func assertCanEncodeNewValue(file: StaticString = #file, line: UInt = #line) {
        precondition(encoder.canEncodeNewValue, """
            Attempt to encode value through single value container \
            when previously value already encoded. codingPath: \(codingPath)
            """, file: file, line: line)
    }
}
