import Foundation

internal struct SingleValueObjectDecodingContainer: SingleValueDecodingContainer {
    private let decoder: ObjectDecoder
    
    let codingPath: [CodingKey]
    
    init(referencing decoder: ObjectDecoder, codingPath: [CodingKey]) {
        self.decoder = decoder
        self.codingPath = codingPath
    }
    
    func decodeNil() -> Bool {
        let value = decoder.storage.topContainer
        return decoder.nilDecodingStrategy.isNilValue(value)
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        return try Bool(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        return try Int(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        return try Int8(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        return try Int16(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        return try Int32(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        return try Int64(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        return try UInt(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try UInt8(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try UInt16(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try UInt32(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try UInt64(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        return try Float(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        return try Double(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode(_ type: String.Type) throws -> String {
        return try String(value: decoder.storage.topContainer, codingPath: decoder.codingPath)
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try decoder.unbox(decoder.storage.topContainer, as: type)
    }
}
