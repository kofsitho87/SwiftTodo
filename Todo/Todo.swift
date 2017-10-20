
import Foundation


class TGroup: NSObject {
    var id: Int!
    var title: String!
    var count: Int!
}

class Todo: NSObject {
    var id: Int! = nil
    var gid: Int! = nil
    
    var user: User!
    
    var content: String! = ""
    var completed: Bool = false
}
