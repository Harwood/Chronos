//
//  StudentUtilities.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import CloudKit
import Foundation

struct StudentUtilities {
    
    static func checkInStudent(withId id:String) {
        if DatabaseAPI.isICloudAvailable() {
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyyMMdd:HHmm"
            
            
            let attendanceRecord =
                CKRecord(recordType: "Attendance",
                         recordID: CKRecordID(recordName: "\(id) - \(dayTimePeriodFormatter.string(from: Date()))"))
            
            attendanceRecord.setObject(
                CKReference(recordID: CKRecordID(recordName: id),
                            action: .deleteSelf),
                forKey: "Student")
            
            DatabaseAPI.save(type: .publicRecord,
                             record: attendanceRecord,
                             completionHandler: { (record, error) -> Void in
                                if error == nil {
                                    print("Successfully checked in student \(id)", terminator: "")
                                } else {
                                    print("Error checking in student \(id)", terminator: "")
                                }
            })
        } else {
            // TODO - implement iCloud not available for student checkin
        }
    }
    
}
