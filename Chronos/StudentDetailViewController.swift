import UIKit
import CloudKit

class StudentDetailViewController: UITableViewController {

    private let attendance:[String] = []
    
    var studentRowNumber:Int?
    var studentId:String?
    var studentRecord:CKRecord?
    
    let db = DatabaseAPI.sharedInstance
    
    override func viewDidLoad() -> Void {
        super.viewDidLoad()

        self.title = self.db.students[self.studentRowNumber!].name
        
        self.tableView.editing = false
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        self.studentId = self.db.students[self.studentRowNumber!].id
        self.studentRecord = self.db.students[self.studentRowNumber!].ckRecord

        self.db.studentAttendance.removeAll()

        dispatch_async(dispatch_get_main_queue()) {
            self.fetchStudentAttendanceWithRecord(self.studentRecord!)
        }
    }
    
    func refresh(sender:AnyObject) -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchStudentAttendanceWithRecord(self.studentRecord!)
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentDetailCell", forIndexPath: indexPath)

        cell.textLabel?.text = self.db.studentAttendance[indexPath.row]

        return cell
    }

    func fetchStudentAttendanceWithRecord(studentRecord: CKRecord) {
        let predicate = NSPredicate(format: "%K == %@", "Student" ,CKReference(recordID: studentRecord.recordID, action: CKReferenceAction.None))
        self.db.performPublicQuery(
            CKQuery(recordType: "Attendance", predicate: predicate),
            inZoneWithID: nil) { results, error in
                if error != nil {
                    print("Error geting classes")
                } else {
                    if results!.count > 0 {
                        print(results)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.db.updateStudentAttendanceList(results)
                            
                            self.tableView?.reloadData()
                        }
                    }
                }
        }
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.db.studentAttendance.count
    }
}