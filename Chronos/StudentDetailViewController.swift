import UIKit
import CloudKit
import MessageUI
import SVWebViewController

class StudentDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    private let attendance:[String] = []
    
    var studentRowNumber:Int?
    var studentId:String?
    var studentName:String?
    var studentRecord:CKRecord?
    
    let db = DatabaseAPI.sharedInstance
    let report = ReportAPI.sharedInstance
    
    override func viewDidLoad() -> Void {
        super.viewDidLoad()

        self.studentName = self.db.students[self.studentRowNumber!].name

        self.title = self.studentName
        
        self.tableView.editing = false
        
        self.refreshControl?.addTarget(self, action: #selector(StudentDetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

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
                    print("Error geting classes", terminator: "")
                } else {
                    if results!.count > 0 {
                        print(results, terminator: "")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.db.updateStudentAttendanceList(results)
                            
                            self.tableView?.reloadData()
                        }
                    }
                }
        }
    }

    @IBAction func reportButtonAction(sender: UIBarButtonItem) {
        let filename = "\(self.studentId!)_report"

        self.report.createReport(forStrudent: self.studentName!, withID: self.studentId!, withFilename: filename)
/*
        let webViewController:SVModalWebViewController = SVModalWebViewController(URLRequest: self.report.generateURLRequestForReport(withName: filename))
        webViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet

        presentViewController(webViewController, animated: true, completion: nil)
*/

        if (MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self

            mailComposer.setSubject("Student Attendance Report : \(self.studentName!) (\(self.studentId!))")
            mailComposer.setMessageBody("", isHTML: false)


            let filePath = self.report.getDocumentPath(withName: filename).stringByAppendingPathComponent(filename+".html")
            if let fileData = NSData(contentsOfFile: filePath) {
                    mailComposer.addAttachmentData(fileData, mimeType: "text/html", fileName: "Student Attendance - \(self.studentId)")

            }

            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }

    internal func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.db.studentAttendance.count
    }
}

extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}