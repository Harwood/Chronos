//
//  DatabaseAPI.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import CloudKit
import Foundation

struct DatabaseAPI {
    
    fileprivate static let publicDatabase = CKContainer.default().publicCloudDatabase
    fileprivate static let privateDatabase = CKContainer.default().privateCloudDatabase
    
    fileprivate static let syncQueue = DispatchQueue(label: "DatabaseAPI.syncQueue")
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    enum DatabaseType {
        case publicRecord
        case privateRecord
    }
    
    static func isICloudAvailable() -> Bool{
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
    
    static func fetch(type:DatabaseType,
               withRecordID recordID:CKRecordID,
               completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        syncQueue.async {
            switch type {
            case .privateRecord:
                self.privateDatabase.fetch(withRecordID: recordID,
                                           completionHandler: completionHandler)
            case .publicRecord:
                self.publicDatabase.fetch(withRecordID: recordID,
                                          completionHandler: completionHandler)
            }
        }
    }
    
    static func save(type:DatabaseType, record:CKRecord,
              completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        switch type {
        case .privateRecord:
            self.publicDatabase.save(record,
                                     completionHandler: completionHandler)
        case .publicRecord:
            self.publicDatabase.save(record,
                                     completionHandler: completionHandler)
        }
    }
    
    static func search(type:DatabaseType,
                withQuery query:CKQuery,
                inZoneWith zoneID:CKRecordZoneID?,
                completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        
        switch type {
        case .privateRecord:
            self.privateDatabase.perform(query,
                                         inZoneWith: zoneID,
                                         completionHandler: completionHandler)
        case .publicRecord:
            self.publicDatabase.perform(query,
                                        inZoneWith: zoneID,
                                        completionHandler: completionHandler)
        }
    }
    
    static func delete(type:DatabaseType,
                withRecordID recordID:CKRecordID,
                completionHandler: @escaping (CKRecordID?, Error?) -> Void) {
        
        switch type {
        case .privateRecord:
            self.privateDatabase.delete(withRecordID: recordID,
                                        completionHandler: completionHandler)
        case .publicRecord:
            self.publicDatabase.delete(withRecordID: recordID,
                                       completionHandler: completionHandler)
        }
    }
}
