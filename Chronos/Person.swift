//
//  Person.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import Foundation

class Person {
    var name: String
    var id: String
    
    init(withName name:String, andId id:String) {
        self.name = name
        self.id = id
    }
}
