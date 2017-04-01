//
//  ChronosTests.swift
//  ChronosTests
//
//  Created by Carter Harwood on 2/4/17.
//  Copyright © 2017 Carter Harwood. All rights reserved.
//

import XCTest
import CloudKit
@testable import Chronos

class ChronosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testICloudAvailability() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(DatabaseAPI.isICloudAvailable())
    }
    
    
    func testDbApiTest() {
        let studentID = "000596726"
        
        let expect = expectation(description: "")
        
        self.measure {
            DatabaseAPI.fetch(type: .publicRecord,
                              withRecordID: CKRecordID(recordName: studentID),
                              completionHandler: { record, error in
                                XCTAssertNil(error)
                                XCTAssertNotNil(record)
                                
                                let student = Converter.student(fromCKRecord: record!)
                                
                                XCTAssertEqual("000596726", student.id)
                                XCTAssertEqual("AJ Longbrake", student.name)
                                
                                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 10, handler: { (error) in
            XCTAssertNil(error, "Test timed out. \(String(describing: error?.localizedDescription))")
        })
    }
}
