import Foundation

internal protocol InitializableWithAny {
    init(value: Any, codingPath: [CodingKey]) throws
}

extension Bool: InitializableWithAny {
    init(value: Any, codingPath: [CodingKey]) throws {
        let type = Bool.self
        guard let boolean = value as? Bool else {
            throw Errors.typeMismatch(codingPath: codingPath, expectation: type, reality: value)
        }
        self = boolean
    }
}

extension String: InitializableWithAny {
    init(value: Any, codingPath: [CodingKey]) throws {
        let type = String.self
        guard let string = value as? String else {
            throw Errors.typeMismatch(codingPath: codingPath, expectation: type, reality: value)
        }
        self = string
    }
}

extension InitializableWithAny where Self: InitializableWithNumeric {
    init(value: Any, codingPath: [CodingKey]) throws {
        let type = Self.self
        
        switch value {
        case let num as Int:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Int8:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Int16:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Int32:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Int64:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as UInt:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as UInt8:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as UInt16:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as UInt32:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as UInt64:
            guard let exactNum = Self(integer: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Float:
            guard let exactNum = Self(floatingPoint: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        case let num as Double:
            guard let exactNum = Self(floatingPoint: num) else {
                throw Errors.dataCorrupted(codingPath: codingPath, expectation: type, reality: num)
            }
            self = exactNum
        default:
            throw Errors.typeMismatch(codingPath: codingPath, expectation: type, reality: value)
        }
    }
}

// MARK: -

internal protocol InitializableWithNumeric {
    init?<T>(integer value: T) where T: BinaryInteger
    init?<T>(floatingPoint value: T) where T: BinaryFloatingPoint
}

extension InitializableWithNumeric where Self: Numeric {
    init?<T>(integer value: T) where T: BinaryInteger {
        self.init(exactly: value)
    }
}

extension InitializableWithNumeric where Self: BinaryInteger {
    init?<T>(floatingPoint value: T) where T: BinaryFloatingPoint {
        self.init(exactly: value)
    }
}

extension InitializableWithNumeric where Self: BinaryFloatingPoint {
    init?<T>(floatingPoint value: T) where T: BinaryFloatingPoint {
        if value.isNaN {
            self = Self.nan
        } else if let exactValue = Self(exactly: value) {
            self = exactValue
        } else {
            return nil
        }
    }
}

extension Int: InitializableWithAny, InitializableWithNumeric {}
extension Int8: InitializableWithAny, InitializableWithNumeric {}
extension Int16: InitializableWithAny, InitializableWithNumeric {}
extension Int32: InitializableWithAny, InitializableWithNumeric {}
extension Int64: InitializableWithAny, InitializableWithNumeric {}
extension UInt: InitializableWithAny, InitializableWithNumeric {}
extension UInt8: InitializableWithAny, InitializableWithNumeric {}
extension UInt16: InitializableWithAny, InitializableWithNumeric {}
extension UInt32: InitializableWithAny, InitializableWithNumeric {}
extension UInt64: InitializableWithAny, InitializableWithNumeric {}
extension Float: InitializableWithAny, InitializableWithNumeric {}
extension Double: InitializableWithAny, InitializableWithNumeric {}
