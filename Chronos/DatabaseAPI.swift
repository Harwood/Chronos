//
//  DatabaseAPI.swift
//  Chronos
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import CloudKit
import Foundation


/// Wrapper for interacting consistantly with CloudKit
///
/// - author: Carter Harwood <Harwood@users.noreply.github.com>
/// - date: 2017.02.04
struct DatabaseAPI {
    
    private static let syncQueue = DispatchQueue(label: "DatabaseAPI.syncQueue")
    
    /// Prevents others from using the default '()' initializer for this class.
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    private init() {}
    
    ///
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
     enum DatabaseType {
        case privateRecord
        case publicRecord
        case sharedRecord
        
        /// Provides an instance of requested iCloud database
        ///
        /// - author: Carter Harwood <Harwood@users.noreply.github.com>
        /// - date: 2017.02.04
        fileprivate var instance: CKDatabase {
            switch self {
            case .privateRecord:
                return CKContainer.default().privateCloudDatabase
            case .publicRecord:
                return CKContainer.default().publicCloudDatabase
            case .sharedRecord:
                return CKContainer.default().sharedCloudDatabase
            }
        }
    }
    
    
    /// Check if device is logged into iCloud and app has permission
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    static func isICloudAvailable() -> Bool{
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
    
    /// Perform a fetch request against specified iCloud database
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    static func fetch(type database:DatabaseType,
                      withRecordID recordID:CKRecordID,
                      completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        syncQueue.async {
            database.instance.fetch(withRecordID: recordID,
                                    completionHandler: completionHandler)
        }
    }
    
    ///
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    static func save(type database:DatabaseType, record:CKRecord,
                     completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        
        syncQueue.async {
            database.instance.save(record,
                                   completionHandler: completionHandler)
        }
    }
    
    ///
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    static func search(type database:DatabaseType,
                       withQuery query:CKQuery,
                       inZoneWith zoneID:CKRecordZoneID?,
                       completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        
        syncQueue.async {
            database.instance.perform(query,
                             inZoneWith: zoneID,
                             completionHandler: completionHandler)
        }
    }
    
    ///
    ///
    /// - author: Carter Harwood <Harwood@users.noreply.github.com>
    /// - date: 2017.02.04
    static func delete(type database:DatabaseType,
                       withRecordID recordID:CKRecordID,
                       completionHandler: @escaping (CKRecordID?, Error?) -> Void) {
        
        syncQueue.async {
            database.instance.delete(withRecordID: recordID,
                            completionHandler: completionHandler)
        }
    }
}
