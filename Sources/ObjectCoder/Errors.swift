import Foundation

internal enum Errors {
    // MARK: - Encoding Errors
    static func topLevelDidNotEncode(topLevel value: Any) -> EncodingError {
        let desc = "Top-level \(type(of: value)) did not encode any values."
        let context = EncodingError.Context(codingPath: [], debugDescription: desc)
        return EncodingError.invalidValue(value, context)
    }
    
    static func keyNotFound(codingPath: [CodingKey], key: CodingKey) -> DecodingError {
        let desc = "No value associated with key \(key) (\"\(key.stringValue)\")."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.keyNotFound(key, context)
    }
    
    // MARK: - Decoding Errors
    
    static func valueNotFound(
        codingPath: [CodingKey], expectation: Any.Type) -> DecodingError {
        
        let desc = "Expected \(expectation) value but found nil instead."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(expectation, context)
    }
    
    static func typeMismatch(
        codingPath: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
        
        let desc = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.typeMismatch(expectation, context)
    }
    
    static func dataCorrupted<T1, T2: Numeric>(
        codingPath: [CodingKey], expectation: T1.Type, reality: T2) -> DecodingError {
        
        let desc = "Parsed number <\(reality)> does not fit in \(expectation)."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.dataCorrupted(context)
    }
}

internal enum KeyedContainerErrors {
    static func nestedContainerNotFound<NestedKey: CodingKey>(
        codingPath: [CodingKey], key: CodingKey, keyType: NestedKey.Type) -> DecodingError {
        
        let desc = "Cannot get nested keyed container -- "
            + "no value found for key \"\(key.stringValue)\"."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, context)
    }
    
    static func nestedUnkeyedContainerNotFound(
        codingPath: [CodingKey], key: CodingKey) -> DecodingError {
        
        let desc = "Cannot get nested unkeyed container -- "
            + "no value found for key \"\(key.stringValue)\"."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }
}

internal enum UnkeyedContainerErrors {
    static func nestedContainerNotFound<NestedKey: CodingKey>(
        codingPath: [CodingKey], keyType: NestedKey.Type) -> DecodingError {
        
        let desc = "Cannot get nested keyed container -- unkeyed container is at end."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, context)
    }
    
    static func nestedUnkeyedContainerNotFound(codingPath: [CodingKey]) -> DecodingError {
        let desc = "Cannot get nested unkeyed container -- unkeyed container is at end."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }
    
    static func superDecoderNotFound(codingPath: [CodingKey]) -> DecodingError {
        let desc = "Cannot get superDecoder() -- unkeyed container is at end."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.valueNotFound(Decoder.self, context)
    }
}
