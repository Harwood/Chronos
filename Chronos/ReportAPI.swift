import Foundation
import UIKit
import SVWebViewController

/*
Handles the generation of PDF files
*/
final class ReportAPI {
    static let sharedInstance = ReportAPI()

    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

    let db = DatabaseAPI.sharedInstance

    var html:String = ""

    private init() {} //This prevents others from using the default '()' initializer for this class.

    func createReport(forStrudent studentName:String, withID studentID:String, withFilename filename:String) {

        self.generateReportHTML(forStrudent: studentName, withID: studentID)

        do {
            try self.html.writeToFile("\(self.documentsPath)/\(filename).html", atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            print("failed to save html", terminator: "")
        }

    }

    private func generateReportHTML(forStrudent studentName:String, withID studentID:String) {
        self.html = ""
        self.htmlAddHeader(forStrudent: studentName, withID: studentID)
        self.htmlAddBody(forStrudent: studentName, withID: studentID)
    }


    func generateURLRequestForReport(withName filename:String) -> NSURLRequest {
        let filePath = "\(self.documentsPath)/\(filename).html"
        let url = NSURL(fileURLWithPath: filePath)
        let urlRequest = NSURLRequest(URL: url)

        return urlRequest
    }

    private func htmlAddHeader(forStrudent studentName:String, withID studentID:String) {
        self.html.appendContentsOf("<head><title>Student Report : \(studentName) (\(studentID))</title></head>")
    }

    private func htmlAddBody(forStrudent studentName:String, withID studentID:String) {
        self.html.appendContentsOf("<boby>")
        self.html.appendContentsOf("<h2>Student Report : \(studentName) (\(studentID))</h2>")
        self.html.appendContentsOf(self.generateCheckinTable())
        self.html.appendContentsOf("</boby>")
    }

    private func generateCheckinTable() -> String {
        var tmpHtml = "<table>"

        for checkin in self.db.studentAttendance {
            tmpHtml.appendContentsOf("<tr>\(checkin)</tr>")
        }

        tmpHtml.appendContentsOf("</table>")

        return tmpHtml
    }
}