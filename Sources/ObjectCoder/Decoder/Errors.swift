import Foundation

internal enum Errors {
    static func keyNotFound(codingPath: [CodingKey], key: CodingKey) -> DecodingError {
        let desc = "No value associated with key \(key) (\"\(key.stringValue)\")."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: desc)
        return DecodingError.keyNotFound(key, context)
    }
    
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
