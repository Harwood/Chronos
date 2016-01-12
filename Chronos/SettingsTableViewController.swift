//
//  SettingsTableViewController.swift
//  Chronos
//
//  Created by Jordan Harwood on 1/11/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import Foundation

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}