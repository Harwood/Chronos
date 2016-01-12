import UIKit
import CloudKit

class StudentsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
//    var students = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
//        "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
//        "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
//        "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
//        "Pear", "Pineapple", "Raspberry", "Strawberry"]
    
    var students:[(name: String, id: String)] = []
    
    let database:CKDatabase = CKContainer.defaultContainer().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.editing = false
        
        self.fetchStudents()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = self.students[indexPath.row].name
        
        return cell
    }
    
    func fetchStudents() {
        database.performQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)),
            inZoneWithID: nil) { results, error in
            if error != nil {
                print("Error geting classes")
            } else {
                if results!.count > 0 {
                    print(results)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        for result in results! {
                            let student = result as CKRecord
                            
                            let name = student.objectForKey("Name")
                            
                            let id = student.recordID.recordName
                            
                            self.students.append((name: name as! String, id: id))
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}