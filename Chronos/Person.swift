//
//  Person.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import Foundation


///
///
/// - author: Carter Harwood <Harwood@users.noreply.github.com>
/// - date: 2017.02.04
class Person {
    var name: String
    var id: String
    
    /// Init
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    /// - parameter name: name of person
    /// - parameter id: id of person
    init(withName name:String, andId id:String) {
        self.name = name
        self.id = id
    }
}
