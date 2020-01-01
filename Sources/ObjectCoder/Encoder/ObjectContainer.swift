import Foundation

internal protocol ObjectContainer {
    var object: Any { get }
}

internal class DictionaryContainer: ObjectContainer {
    private var dictionary: [String: Any] = [:]
    
    var object: Any { return dictionary }
    
    func set<Key: CodingKey>(_ value: Any, for key: Key) {
        dictionary[key.stringValue] = value
    }
}

internal class ArrayContainer: ObjectContainer {
    private var array: [Any] = []
    
    var object: Any { return array }
    
    var count: Int {
        return array.count
    }
    
    func append(_ value: Any) {
        array.append(value)
    }
    
    func replace(at index: Int, with value: Any) {
        array[index] = value
    }
}

internal class AnyContainer: ObjectContainer {
    private(set) var object: Any
    
    init(object: Any) {
        self.object = object
    }
}
