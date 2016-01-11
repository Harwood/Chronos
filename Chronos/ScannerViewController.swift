
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
    
    let database = CKContainer.defaultContainer().publicCloudDatabase
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    // Checking if user is signed into iCloud on the device
    func isICloudAvailable() -> Bool{
        if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
    
    func displayAlertWithTitle(title: String, message: String) {
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // If not signed into iCloud notify the user that they need to before using the app
        if !isICloudAvailable() {
            displayAlertWithTitle("iCloud", message: "iCloud is not available." +
            " Please sign into your iCloud account and restart this app")
        }

        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
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
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
//        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
                
                //messageLabel.text = metadataObj.stringValue
                getStudent(metadataObj.stringValue)
            }
        }
    }
    
    @IBAction func addStudentAction(sender: UIBarButtonItem) {
        
        //1. Create the alert controller.
        var alert = UIAlertController(title: "Add Student", message: "Enter a text", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (nameField) -> Void in
            nameField.placeholder = "John Smith"
            nameField.text = ""
        })
        
        alert.addTextFieldWithConfigurationHandler({ (idField) -> Void in
            idField.placeholder = "123456789"
            idField.text = ""
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            let studentName = (alert.textFields![0] as UITextField).text
            let studentID = (alert.textFields![1] as UITextField).text
            
            let studentRecord = CKRecord(recordType: "Student", recordID: CKRecordID(recordName: studentID!))
            studentRecord.setObject(studentName, forKey: "Name")
            
            self.database.saveRecord(studentRecord, completionHandler: { (record, error) -> Void in
                if error != nil {
                    print("Error geting classes")
                }
                
                self.displayAlertWithTitle("Student Added", message: studentName! + " has been added to records.")
                
                self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID!)!)
                
            })
            
            NSLog("OK Pressed")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        })
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func getStudent(studentID: String)  {
        if !self.foundIDs.contains(studentID) {
            self.foundIDs.append(studentID)
            
            database.fetchRecordWithID(CKRecordID(recordName: studentID), completionHandler: { fetchedStudent, error in
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
    
    func checkStudentIn(studentID:String, studentName:String) {
        let attendanceRecord = CKRecord(recordType: "Attendance")
        attendanceRecord.setObject(
            CKReference(recordID: CKRecordID(recordName: studentID),
                action: CKReferenceAction.DeleteSelf), forKey: "Student")
        
        
        database.saveRecord(attendanceRecord, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error geting classes")
            }
            
            self.displayAlertWithTitle("Student Checked In", message: studentName + " has been checked in.")
            
            self.foundIDs.removeAtIndex(self.foundIDs.indexOf(studentID)!)
            
        })
    }
}