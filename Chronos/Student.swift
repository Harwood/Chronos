import Foundation

class Student {
    let name:String?
    let id:String
    
    private init() {
        self.name = ""
        self.id = ""
    }
    
    init(name:String, id:String) {
        self.name = name
        self.id = id
    }
}