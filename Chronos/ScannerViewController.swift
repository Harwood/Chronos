
// displayAlerWithTitle, isICloudAvailable from 'swift tutorials' on Youtube ( https://www.youtube.com/watch?v=olEvXlpqmsU )
import UIKit
import AVFoundation
import CloudKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    
    @IBOutlet var extraButton:UIBarButtonItem!

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    var foundIDs = [String]()

    // let database = CKContainer.defaultContainer().publicCloudDatabase
    
    let db = DatabaseAPI.sharedInstance
    
    let UISharedApplication = UIApplication.shared
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    func displayAlertWithTitle(_ title: String, message: String) {
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .default,
            handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    func sendLocalNotification(withAlert alertMsg:String, onDate alertDate:Date?=Date()) {
//        let notification = UILocalNotification()
//        notification.alertBody = alertMsg // text that will be displayed in the notification
//        //notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
//        notification.fireDate = alertDate
//        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
//        //notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
//        //notification.category = "TODO_CATEGORY"
//        
//        UISharedApplication.scheduleLocalNotification(notification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(revealViewController().revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Register for Push Notifications
//        UISharedApplication.registerUserNotificationSettings(
//            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
//        UISharedApplication.registerForRemoteNotifications()

        // If not signed into iCloud notify the user that they need to before using the app
        if !self.db.isICloudAvailable() {
            displayAlertWithTitle("iCloud", message: "iCloud is not available." +
            " Please sign into your iCloud account and restart this app")
        }

        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error, terminator: "")
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedBarCodes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                getStudent(metadataObj.stringValue)
            }
        }
    }

    func getStudent(_ studentID: String)  {
        if !self.foundIDs.contains(studentID) {
            DispatchQueue.main.async {
                self.foundIDs.append(studentID)
                
                self.db.fetchPublicRecordWithID(CKRecordID(recordName: studentID), completionHandler: { fetchedStudent, error in
                    guard let fetchedStudent = fetchedStudent else {
                        print("ERROR IN GETTING STUDENT!", terminator: "")
                        self.foundIDs.remove(at: self.foundIDs.index(of: studentID)!)
                        return
                    }
                    
                    let studentName = fetchedStudent["Name"] as? String ?? "Unnamed Student"
                    
                    self.checkStudentIn(studentID, studentName: studentName)
                })
            }
        }
    }

    /**
     Adds entry of attendance to CloudKit database
    */
    func checkStudentIn(_ studentID:String, studentName:String) {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyyMMdd:HHmm"
        
        let recordName = studentID + " - " + dayTimePeriodFormatter.string(from: Date())
        
        let attendanceRecord = CKRecord(recordType: "Attendance", recordID: CKRecordID(recordName: recordName))
        attendanceRecord.setObject(
            CKReference(recordID: CKRecordID(recordName: studentID),
                action: CKReferenceAction.deleteSelf), forKey: "Student")
        
        self.db.savePublicRecord(attendanceRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error geting classes", terminator: "")
            }
            
            self.displayAlertWithTitle("Student Checked In", message: studentName + " has been checked in.")
            
            self.foundIDs.remove(at: self.foundIDs.index(of: studentID)!)
            
        })
    }
}
