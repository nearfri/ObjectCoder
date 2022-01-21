import Foundation

internal class ReferencingEncoder: ObjectEncoderInternal {
    private let referenceCodingPath: [CodingKey]
    private let completion: (_ encodedObject: Any) -> Void
    
    init(referenceCodingPath: [CodingKey], key: CodingKey, options: Options,
         completion: @escaping (_ encodedObject: Any) -> Void) {
        
        self.referenceCodingPath = referenceCodingPath
        self.completion = completion
        super.init(codingPath: referenceCodingPath + [key], options: options)
    }
    
    deinit {
        let encodedObject: Any
        switch storage.count {
        case 0: encodedObject = [:] as [String: Any]
        case 1: encodedObject = storage.popContainer().object
        default:
            preconditionFailure(
                "Referencing encoder deallocated with multiple containers on stack.")
        }
        
        completion(encodedObject)
    }
    
    override var canEncodeNewValue: Bool {
        return storage.count == codingPath.count - referenceCodingPath.count - 1
    }
}
