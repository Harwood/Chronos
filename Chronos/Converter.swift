//
//  Converter.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import CloudKit
import Foundation

struct Converter {
    
    static func student(fromCKRecord ckRecord:CKRecord) -> Student {
        
        return Student(withName: ckRecord.object(forKey: "Name") as! String,
                       andId: ckRecord.recordID.recordName)
    }
}
