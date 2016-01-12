//
//  MapViewController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import CloudKit

class StudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var menuButton:UIBarButtonItem!

    @IBOutlet weak var tblStudents: UITableView!
    
    @IBOutlet var tableView: UITableView!

    let database = CKContainer.defaultContainer().publicCloudDatabase

    var arrStudents: Array<CKRecord> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        fetchStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchStudents() {
        database.performQuery(
            CKQuery(recordType: "Student", predicate: NSPredicate(value: true)),
            inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print("Error geting classes")
            } else {
                print(results)
                
                for result in results! {
                    self.arrStudents.append(result)
                }
                
//                for result in results! {
//                    self.arrNotes.append(result as! CKRecord)
//                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrStudents.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        let studentRecord: CKRecord = arrStudents[indexPath.row]
        
        cell.textLabel?.text = studentRecord.valueForKey("Name") as? String

        cell.detailTextLabel?.text = studentRecord.valueForKey("recordID.recordName") as? String
        
        return cell
    }
}