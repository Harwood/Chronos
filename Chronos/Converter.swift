//
//  Converter.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import CloudKit
import Foundation

/// Untility to handle CKRecord related convertions
///
/// - warning: Currently incomplete
/// - warning: Currently no code to varify record types
/// - author: Carter Harwood <Harwood@users.noreply.github.com>
struct Converter {
    
    /// Converts CKRecord to Student object
    ///
    
    /// - warning: Currently no code to varify it is a Student record
    /// - parameter ckRecord: CKRecord to convert
    /// - returns: Student representation of CKRecord
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    static func student(fromCKRecord ckRecord:CKRecord) -> Student {
        return Student(withName: ckRecord.object(forKey: "Name") as! String,
                       andId: ckRecord.recordID.recordName)
    }
}
