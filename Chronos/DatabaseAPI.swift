import Foundation
import CloudKit

/**
 Handle all database connections with CloudKit
*/
class DatabaseAPI {
    static let sharedInstance = DatabaseAPI()
    
    private let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    private let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    private var foundIDs = [String]()
    
    internal var students:[(name: String, id: String, ckRecord: CKRecord)] = []
    internal var studentAttendance:[String] = []

    /**
     Constructor
    */
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    /** 
    Checking if user is signed into iCloud on the device
    
    - Returns: True if iCloud is available, else false
     */
    func isICloudAvailable() -> Bool{
        if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }

    /**
     Updates local student list from CloudKit
    */
    func updateStudentList(list:[CKRecord]?) {
        self.students.removeAll()
        
        for item in list! {
            let student = item as CKRecord
            
            let name = student.objectForKey("Name")
            
            let id = student.recordID.recordName
            
            self.students.append((name: name as! String, id: id, ckRecord: student))
        }
    }

    /**
     Updates local student attendance list from CloudKit
    */
    func updateStudentAttendanceList(list:[CKRecord]?) {
        self.studentAttendance.removeAll()

        for item in list! {
            let record = item as CKRecord
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            
            let name:String = dateFormatter.stringFromDate(record.creationDate!)
            
            self.studentAttendance.append(name)
        }
    }
    
    /**
     Fetches student with id
     
     - Parameter studentID: ID to match 
     
     - Returns: Student with id
     */
    func getStudent(studentID: String) -> Student {
        var student:Student?
        
        if !self.foundIDs.contains(studentID) {
            dispatch_async(dispatch_get_main_queue()) {
                self.foundIDs.append(studentID)
                
                self.publicDatabase.fetchRecordWithID(CKRecordID(recordName: studentID), completionHandler: { fetchedStudent, error in
                    guard let fetchedStudent = fetchedStudent else {
                        print("ERROR IN GETTING STUDENT!", terminator: "")
                        self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID)!)
                        return
                    }
                    
                    student = Student(name:fetchedStudent["Name"] as? String ?? "Unnamed Student", id:studentID)
                })
            }
        }
        
        return student!
    }
    
    func fetchPublicRecordWithID(recordID: CKRecordID, completionHandler: (CKRecord?, NSError?) -> Void) {
        self.publicDatabase.fetchRecordWithID(recordID, completionHandler: completionHandler)
    }
    
    func performPublicQuery(query: CKQuery, inZoneWithID: CKRecordZoneID?, completionHandler: ([CKRecord]?, NSError?) -> Void) {
        self.publicDatabase.performQuery(query, inZoneWithID: inZoneWithID, completionHandler: completionHandler)
    }
    
    func savePublicRecord(record: CKRecord, completionHandler: (CKRecord?, NSError?) -> Void) {
        self.publicDatabase.saveRecord(record, completionHandler: completionHandler)
    }
    
    func performPrivateQuery(query: CKQuery, inZoneWithID: CKRecordZoneID?, completionHandler: ([CKRecord]?, NSError?) -> Void) {
        self.privateDatabase.performQuery(query, inZoneWithID: inZoneWithID, completionHandler: completionHandler)
    }
    
    func savePrivateRecord(record: CKRecord, completionHandler: (CKRecord?, NSError?) -> Void) {
        self.privateDatabase.saveRecord(record, completionHandler: completionHandler)
    }
    
    
    /**
     Check in student with specified ID
     
     - Parameter studentID: ID of student to check in
     
     - Returns: True if successful, else false
     */
    func checkStudentIn(studentID:String) -> Bool {
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyyMMdd:HHmm"
        
        let recordName = studentID + " - " + dayTimePeriodFormatter.stringFromDate(NSDate())
        
        let attendanceRecord = CKRecord(recordType: "Attendance", recordID: CKRecordID(recordName: recordName))
        attendanceRecord.setObject(
            CKReference(recordID: CKRecordID(recordName: studentID),
                action: CKReferenceAction.DeleteSelf), forKey: "Student")
        
        self.publicDatabase.saveRecord(attendanceRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error geting classes", terminator: "")
            }
            
            self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID)!)
        })
        
        return true
    }
}