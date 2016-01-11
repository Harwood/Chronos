//
//  MapViewController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import CloudKit

class StudentsViewController: UITableViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!

    @IBOutlet weak var tblStudents: UITableView!

    
    let database = CKContainer.defaultContainer().publicCloudDatabase

    var arrStudents: Array<CKRecord> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        fetchStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchStudents() {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Student", predicate: predicate)
        
        database.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                print(results)
                
                for result in results! {
                    self.arrStudents.append(result)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tblStudents.reloadData()
                    self.tblStudents.hidden = false
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellNote", forIndexPath: indexPath)
        
        let studentRecord: CKRecord = arrStudents[indexPath.row]
        
        cell.textLabel?.text = (studentRecord.valueForKey("Name") as? String)! +
            " : " +
            (studentRecord.valueForKey("recordID.recordName") as? String)!
        
        return cell
    }
}
