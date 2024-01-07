//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
// MARK: - SingleValueConatainer
/// When JSON/Container contains only one value then we can use this strategy
let singleData = """
 {"id": "1"}
 """.data(using: .utf8)

class IdDao: Decodable {
    let id: String

    required init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            id = ""
        } else {
            id = try container.decode(String.self)
        }
    }
}
// MARK: - Regular Decoding
let data = """
 {
    "id": "1",
    "Name": "Kroll"
}
""".data(using: .utf8)

class User: Decodable {
    let id: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }
}
let decoder = JSONDecoder()
var decodedData = try! decoder.decode(User.self, from: data ?? Data())
print(decodedData.name)
// MARK: - Flattened Decoding
let nestedData = """
 {
    "id": "1",
    "name": {
    "firstName": "Rohit",
    "lastName": "Sharma"
 }
 }
 """.data(using: .utf8)
class NestedUser: Decodable {
    let id: String
    let firstName: String
    enum RootContainerkey: String, CodingKey {
        case id
        case name
    }
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootContainerkey.self)
        self.id = try container.decode(String.self, forKey: .id)
        let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
        self.firstName = try nameContainer.decode(String.self, forKey: .firstName)
    }
}
let nestedDecodedData = try! decoder.decode(NestedUser.self, from: nestedData ?? Data())
print(nestedDecodedData.firstName)
// MARK: - Decoding Error types
private extension DecodingError {
    var prettyDescription: String {
        switch self {
        case let .typeMismatch(type, context):
            "DecodingError.typeMismatch \(type), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
        case let .valueNotFound(type, context):
            "DecodingError.valueNotFound \(type), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
        case let .keyNotFound(key, context):
            "DecodingError.keyNotFound \(key), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
        case let .dataCorrupted(context):
            "DecodingError.dataCorrupted \(context.prettyDescription), @ ERROR: \(localizedDescription)"
        default:
            "DecodingError: \(localizedDescription)"
        }
    }
}
// MARK: - Decoding Error Context pretty print
private extension DecodingError.Context {
    var prettyDescription: String {
        var result = ""
        if !codingPath.isEmpty {
            result.append(codingPath.map(\.stringValue).joined(separator: "."))
            result.append(": ")
        }
        result.append(debugDescription)
        return result
    }
}
// MARK: - Decoding Errors
let errorData = """
 {
    "id": 1,
    "name": {
        "firstName": "Rohit",
        "lastName": 1,
 }
 }
 """.data(using: .utf8)
class NestedErruser: Decodable {
    var id: String
    var firstName: String
    var lastName: String
    enum RootContainerkey: String, CodingKey {
        case id
        case name
    }
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
    }
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: RootContainerkey.self)
            let nameContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .name)
            self.firstName = try nameContainer.decode(String.self, forKey: .firstName)
        do {
            self.id = try container.decode(String.self, forKey: .id)
            self.lastName = try nameContainer.decode(String.self, forKey: .lastName)
        } catch let err as DecodingError {
            print(err.prettyDescription)
            self.id = try String(container.decode(Int.self, forKey: .id))
            self.lastName = "A"
        }
    }
}
let errorDecodedData = try! decoder.decode(NestedErruser.self, from: errorData ?? Data())
print(errorDecodedData.lastName)

//class MyViewController : UIViewController {
//    override func loadView() {
//        let view = UIView()
//        view.backgroundColor = .white
//
//        let label = UILabel()
//        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
//        label.text = "Hello World!"
//        label.textColor = .black
//
//        view.addSubview(label)
//        self.view = view
//    }
//}
//// Present the view controller in the Live View window
//PlaygroundPage.current.liveView = MyViewController()
