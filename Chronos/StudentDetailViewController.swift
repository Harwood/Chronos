import UIKit
import CloudKit

class StudentDetailViewController: UITableViewController {
    
    private let attendance:[String] = []
    
    var studentID:String?
    
    let db = DatabaseAPI.sharedInstance
    
    override func viewDidLoad() -> Void {
        super.viewDidLoad()
        
        self.tableView.editing = false
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        print(self.studentID!)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchStudentAttendance()
        }
    }
    
    func refresh() -> Void {
        self.fetchStudentAttendance()
    }
    
    func fetchStudentAttendance() {
        self.db.performPublicQuery(
            CKQuery(recordType: "Attendance", predicate: NSPredicate(value: true)),
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