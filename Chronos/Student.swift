import Foundation

/**
 Model to handle students
*/
class Student {
    let name:String?
    let id:String

    /**
     Constructor
    */
    private init() {
        self.name = ""
        self.id = ""
    }

    /**
     Constructor
    */
    init(name:String, id:String) {
        self.name = name
        self.id = id
    }
}
