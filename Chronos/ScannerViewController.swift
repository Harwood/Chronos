
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
    
 //   let database = CKContainer.defaultContainer().publicCloudDatabase
    
    let db = DatabaseAPI.sharedInstance
    
    let UISharedApplication = UIApplication.sharedApplication()
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func sendLocalNotification(withAlert alertMsg:String, onDate alertDate:NSDate?=NSDate()) {
        let notification = UILocalNotification()
        notification.alertBody = alertMsg // text that will be displayed in the notification
        //notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = alertDate
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        //notification.userInfo = ["UUID": item.UUID, ] // assign a unique identifier to the notification so that we can retrieve it later
        //notification.category = "TODO_CATEGORY"
        
        UISharedApplication.scheduleLocalNotification(notification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Register for Push Notifications
        UISharedApplication.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        UISharedApplication.registerForRemoteNotifications()

        // If not signed into iCloud notify the user that they need to before using the app
        if !self.db.isICloudAvailable() {
            displayAlertWithTitle("iCloud", message: "iCloud is not available." +
            " Please sign into your iCloud account and restart this app")
        }

        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())

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
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedBarCodes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                getStudent(metadataObj.stringValue)
            }
        }
    }

    func getStudent(studentID: String)  {
        if !self.foundIDs.contains(studentID) {
            dispatch_async(dispatch_get_main_queue()) {
                self.foundIDs.append(studentID)
                
                self.db.fetchPublicRecordWithID(CKRecordID(recordName: studentID), completionHandler: { fetchedStudent, error in
                    guard let fetchedStudent = fetchedStudent else {
                        print("ERROR IN GETTING STUDENT!")
                        self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID)!)
                        return
                    }
                    
                    let studentName = fetchedStudent["Name"] as? String ?? "Unnamed Student"
                    
                    self.checkStudentIn(studentID, studentName: studentName)
                })
            }
        }
    }
    
    func checkStudentIn(studentID:String, studentName:String) {
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyyMMdd:HHmm"
        
        let recordName = studentID + " - " + dayTimePeriodFormatter.stringFromDate(NSDate())
        
        let attendanceRecord = CKRecord(recordType: "Attendance", recordID: CKRecordID(recordName: recordName))
        attendanceRecord.setObject(
            CKReference(recordID: CKRecordID(recordName: studentID),
                action: CKReferenceAction.DeleteSelf), forKey: "Student")
        
        self.db.savePublicRecord(attendanceRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error geting classes")
            }
            
            self.displayAlertWithTitle("Student Checked In", message: studentName + " has been checked in.")
            
            self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID)!)
            
        })
    }
}