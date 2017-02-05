//
//  Student.swift
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
class Student : Person {
    
    /// Override init
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    /// - parameter name: name of student
    /// - parameter id: id of student
    override init(withName name:String, andId id:String) {
        super.init(withName: name, andId: id)
    }
}
