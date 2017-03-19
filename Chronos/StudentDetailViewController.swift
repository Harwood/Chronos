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
        
        self.tableView.isEditing = false
        
        self.refreshControl?.addTarget(self, action: #selector(StudentDetailViewController.refresh(_:)), for: UIControlEvents.valueChanged)

        self.studentId = self.db.students[self.studentRowNumber!].id
        self.studentRecord = self.db.students[self.studentRowNumber!].ckRecord

        self.db.studentAttendance.removeAll()

        DispatchQueue.main.async {
            self.fetchStudentAttendanceWithRecord(self.studentRecord!)
        }
    }
    
    func refresh(_ sender:AnyObject) -> Void {
        DispatchQueue.main.async {
            self.fetchStudentAttendanceWithRecord(self.studentRecord!)
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentDetailCell", for: indexPath)

        cell.textLabel?.text = self.db.studentAttendance[indexPath.row]

        return cell
    }

    func fetchStudentAttendanceWithRecord(_ studentRecord: CKRecord) {
        let predicate = NSPredicate(format: "%K == %@", "Student" ,CKReference(recordID: studentRecord.recordID, action: CKReferenceAction.none))
        self.db.performPublicQuery(
            CKQuery(recordType: "Attendance", predicate: predicate),
            inZoneWithID: nil) { results, error in
                if error != nil {
                    print("Error geting classes : \(error?.localizedDescription)", terminator: "")
                } else {
                    if results!.count > 0 {
                        print(results!, terminator: "")
                        
                        DispatchQueue.main.async {
                            self.db.updateStudentAttendanceList(results)
                            
                            self.tableView?.reloadData()
                        }
                    }
                }
        }
    }

    @IBAction func reportButtonAction(_ sender: UIBarButtonItem) {
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
            if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                    mailComposer.addAttachmentData(fileData, mimeType: "text/html", fileName: "Student Attendance - \(self.studentId)")

            }

            self.present(mailComposer, animated: true, completion: nil)
        }
    }

    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.db.studentAttendance.count
    }
}

extension String {
    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
