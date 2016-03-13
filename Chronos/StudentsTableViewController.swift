import UIKit
import CloudKit
import SWRevealViewController

class StudentsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let db = DatabaseAPI.sharedInstance
    
    func refresh(sender:AnyObject) {
        self.db.performPublicQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)), inZoneWithID: nil) { results, error in
                
                if error != nil {
                    print("Error geting classes")
                } else {
                    if results!.count > 0 {
                        print(results!)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.db.updateStudentList(results)
                            
                            self.tableView?.reloadData()
                            self.refreshControl?.endRefreshing()
                        }
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.editing = false
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        dispatch_async(dispatch_get_main_queue()) {
            self.fetchStudents()
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.db.students.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let viewController = segue.destinationViewController as! StudentDetailViewController
        viewController.studentRowNumber = tableView.indexPathForSelectedRow!.row
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.db.students[indexPath.row].name
        
        return cell
    }
    
    func fetchStudents() {
        self.db.performPublicQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)),
            inZoneWithID: nil) { results, error in
                if error != nil {
                    print("Error geting classes")
                } else {
                    if results!.count > 0 {
                        print(results)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.db.updateStudentList(results)
                            
                            self.tableView?.reloadData()
                        }
                    }
                }
        }
    }

    
    @IBAction func addStudentAction(sender: UIBarButtonItem) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Student", message: "Enter a text", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (nameField) -> Void in
            nameField.placeholder = "John Smith"
            nameField.text = ""
        })
        
        alert.addTextFieldWithConfigurationHandler({ (idField) -> Void in
            idField.placeholder = "123456789"
            idField.text = ""
            idField.keyboardType = UIKeyboardType.NumberPad
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            let studentName = (alert.textFields![0] as UITextField).text
            let studentID = (alert.textFields![1] as UITextField).text
            
            let studentRecord = CKRecord(recordType: "Student", recordID: CKRecordID(recordName: studentID!))
            studentRecord.setObject(studentName, forKey: "Name")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.db.savePublicRecord(studentRecord, completionHandler: { (record, error) -> Void in
                    if error != nil {
                        print("Error geting classes")
                    }
                    
                    self.fetchStudents()
                })
            }
            
            
            NSLog("OK Pressed")
            })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            })
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
}