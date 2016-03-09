import Foundation

/**
 Handles settings menu
*/
class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    /**
     Handles view loading
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}