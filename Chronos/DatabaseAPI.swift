import Foundation
import CloudKit

/**
 Handle all database connections with CloudKit
*/
class DatabaseAPI {
    static let sharedInstance = DatabaseAPI()
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
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
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }

    /**
     Updates local student list from CloudKit
    */
    func updateStudentList(_ list:[CKRecord]?) {
        self.students.removeAll()
        
        for item in list! {
            let student = item as CKRecord
            
            let name = student.object(forKey: "Name")
            
            let id = student.recordID.recordName
            
            self.students.append((name: name as! String, id: id, ckRecord: student))
        }
    }

    /**
     Updates local student attendance list from CloudKit
    */
    func updateStudentAttendanceList(_ list:[CKRecord]?) {
        self.studentAttendance.removeAll()

        for item in list! {
            let record = item as CKRecord
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            
            let name:String = dateFormatter.string(from: record.creationDate!)
            
            self.studentAttendance.append(name)
        }
    }
    
    /**
     Fetches student with id
     
     - Parameter studentID: ID to match 
     
     - Returns: Student with id
     */
    func getStudent(_ studentID: String) -> Student {
        var student:Student?
        
        if !self.foundIDs.contains(studentID) {
            DispatchQueue.main.async {
                self.foundIDs.append(studentID)
                
                self.publicDatabase.fetch(withRecordID: CKRecordID(recordName: studentID), completionHandler: { fetchedStudent, error in
                    guard let fetchedStudent = fetchedStudent else {
                        print("ERROR IN GETTING STUDENT!", terminator: "")
                        self.foundIDs.remove(at: self.foundIDs.index(of: studentID)!)
                        return
                    }
                    
                    student = Student(name:fetchedStudent["Name"] as? String ?? "Unnamed Student", id:studentID)
                })
            }
        }
        
        return student!
    }
    
    func fetchPublicRecordWithID(_ recordID: CKRecordID, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        self.publicDatabase.fetch(withRecordID: recordID, completionHandler: completionHandler)
    }
    
    func performPublicQuery(_ query: CKQuery, inZoneWithID: CKRecordZoneID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        self.publicDatabase.perform(query, inZoneWith: inZoneWithID, completionHandler: completionHandler)
    }
    
    func savePublicRecord(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        self.publicDatabase.save(record, completionHandler: completionHandler)
    }
    
    func performPrivateQuery(_ query: CKQuery, inZoneWithID: CKRecordZoneID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        self.privateDatabase.perform(query, inZoneWith: inZoneWithID, completionHandler: completionHandler)
    }
    
    func savePrivateRecord(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        self.privateDatabase.save(record, completionHandler: completionHandler)
    }
    
    
    /**
     Check in student with specified ID
     
     - Parameter studentID: ID of student to check in
     
     - Returns: True if successful, else false
     */
    func checkStudentIn(_ studentID:String) -> Bool {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyyMMdd:HHmm"
        
        let recordName = studentID + " - " + dayTimePeriodFormatter.string(from: Date())
        
        let attendanceRecord = CKRecord(recordType: "Attendance", recordID: CKRecordID(recordName: recordName))
        attendanceRecord.setObject(
            CKReference(recordID: CKRecordID(recordName: studentID),
                action: CKReferenceAction.deleteSelf), forKey: "Student")
        
        self.publicDatabase.save(attendanceRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error geting classes", terminator: "")
            }
            
            self.foundIDs.remove(at: self.foundIDs.index(of: studentID)!)
        })
        
        return true
    }
}
