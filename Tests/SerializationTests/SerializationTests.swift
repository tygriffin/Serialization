import XCTest
@testable import Serialization

//
// Primary Models
//
struct CertificateBundle {
    var reference: String = ""
    var quantity: Int = 0
}

struct Creation {
    var registrationCode: String = ""
    var passed : Int = 0
}

//
// Serializable Extensions
//
extension CertificateBundle : Serializable {
    func makeSerializer() -> CertificateBundleSerializer {
        var s = CertificateBundleSerializer()
        s.model = self
        return s
    }
}

extension Creation : Serializable {

    func makeSerializer() -> CreationSerializer {
        var s = CreationSerializer()
        s.model = self
        return s
    }
}

class User {
    var givenName: String = ""
}

//
// Serializers
//
final class CertificateBundleSerializer : Serializer {
    static var type: StorableType = .certificateBundle
    var model = CertificateBundle()
    var storeId: String { return model.reference }
    
    var user: User = User()
    
    lazy var fields: [Field] = {
        return [
            Field(key: "reference", model.reference),
            Field(key: "quantity", model.quantity),
        ]
    }()
    
    var resources = [
        Resource(Creation(registrationCode: "regcode", passed: 3)),
    ]

}

final class CreationSerializer : Serializer {
    
    static var type: StorableType = .creation
    var model = Creation()
    var storeId: String { return model.registrationCode }
    
    lazy var fields: [Field] = {
        return [
            Field(
                key: "registrationCode",
                model.registrationCode
            ),
            Field(key: "passed", model.passed),
        ]
    }()
    
    var resources: [Resource] = [
        Resource(Creation(registrationCode: "regcode", passed: 3)),
    ]
}

final class SerializationTests: XCTestCase {
    
    func testExample() {
        
        do {
            
            let cb = CertificateBundle(reference: "ref", quantity: 34)
            
            
            let s = cb.makeSerialization()
            

            let jsonEncoder = JSONEncoder()
            let json = try jsonEncoder.encode(s)
            try pretty(json)

            
        } catch {
            print(error)
        }
    }
    
    func pretty(_ data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let pretty = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        print(String(data: pretty, encoding: .utf8)!)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
