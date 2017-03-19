import UIKit
import CloudKit
import SWRevealViewController

class StudentsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let db = DatabaseAPI.sharedInstance
    
    func refresh(_ sender:AnyObject) {
        self.db.performPublicQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)), inZoneWithID: nil) { results, error in
                
                if error != nil {
                    print("Error geting classes", terminator: "")
                } else {
                    if results!.count > 0 {
                        print(results!, terminator: "")
                        
                        DispatchQueue.main.async {
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
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.isEditing = false
        
        self.refreshControl?.addTarget(self, action: #selector(StudentsTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)

        DispatchQueue.main.async {
            self.fetchStudents()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.db.students.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let viewController = segue.destination as! StudentDetailViewController
        viewController.studentRowNumber = tableView.indexPathForSelectedRow!.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        cell.textLabel?.text = self.db.students[indexPath.row].name
        
        return cell
    }
    
    func fetchStudents() {
        self.db.performPublicQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)),
            inZoneWithID: nil) { results, error in
                if error != nil {
                    print("Error geting classes", terminator: "")
                } else {
                    if results!.count > 0 {
                        print(results!, terminator: "")
                        
                        DispatchQueue.main.async {
                            self.db.updateStudentList(results)
                            
                            self.tableView?.reloadData()
                        }
                    }
                }
        }
    }

    
    @IBAction func addStudentAction(_ sender: UIBarButtonItem) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Student", message: "Enter a text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (nameField) -> Void in
            nameField.placeholder = "John Smith"
            nameField.text = ""
        })
        
        alert.addTextField(configurationHandler: { (idField) -> Void in
            idField.placeholder = "123456789"
            idField.text = ""
            idField.keyboardType = UIKeyboardType.numberPad
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            let studentName = (alert.textFields![0] as UITextField).text
            let studentID = (alert.textFields![1] as UITextField).text
            
            let studentRecord = CKRecord(recordType: "Student", recordID: CKRecordID(recordName: studentID!))
            studentRecord.setObject(studentName as CKRecordValue?, forKey: "Name")
            
            DispatchQueue.main.async {
                self.db.savePublicRecord(studentRecord, completionHandler: { (record, error) -> Void in
                    if error != nil {
                        print("Error geting classes", terminator: "")
                    }
                    
                    self.fetchStudents()
                })
            }
            
            
            NSLog("OK Pressed")
            })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            })
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}
