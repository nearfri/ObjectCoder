import Foundation

internal typealias EncodingStorage = CodingStorage<ObjectContainer>
internal typealias DecodingStorage = CodingStorage<Any>

internal class CodingStorage<T> {
    private var containers: [T] = []
    
    var count: Int {
        return containers.count
    }
    
    var topContainer: T {
        guard let result = containers.last else {
            preconditionFailure("Empty container stack.")
        }
        return result
    }
    
    func pushContainer(_ container: T) {
        containers.append(container)
    }
    
    @discardableResult
    func popContainer() -> T {
        guard let result = containers.popLast() else {
            preconditionFailure("Empty container stack.")
        }
        return result
    }
    
    func removeAll() {
        containers.removeAll()
    }
}
