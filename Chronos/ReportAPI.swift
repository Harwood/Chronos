import Foundation
import UIKit
import SVWebViewController

/*
Handles the generation of PDF files
*/
final class ReportAPI {
    static let sharedInstance = ReportAPI()

    fileprivate let documentsPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    let db = DatabaseAPI.sharedInstance

    var html:String = ""

    fileprivate init() {} //This prevents others from using the default '()' initializer for this class.

    func createReport(forStrudent studentName:String, withID studentID:String, withFilename filename:String) {

        self.generateReportHTML(forStrudent: studentName, withID: studentID)

        do {
            try self.html.write(toFile: "\(self.documentsPath)/\(filename).html", atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print("failed to save html", terminator: "")
        }

        print(documentsPath)

    }

    func getReportData(withName filename:String) -> Data {
        return (try! Data(contentsOf: URL(fileURLWithPath: self.documentsPath+"\(filename).html")))
    }

    func getDocumentPath(withName filename:String) -> String {
        return self.documentsPath
    }

    fileprivate func generateReportHTML(forStrudent studentName:String, withID studentID:String) {
        self.html = ""
        self.htmlAddHeader(forStrudent: studentName, withID: studentID)
        self.htmlAddBody(forStrudent: studentName, withID: studentID)
    }


    func generateURLRequestForReport(withName filename:String) -> URLRequest {
        let filePath = "\(self.documentsPath)/\(filename).html"
        let url = URL(fileURLWithPath: filePath)
        let urlRequest = URLRequest(url: url)

        return urlRequest
    }

    fileprivate func htmlAddHeader(forStrudent studentName:String, withID studentID:String) {
        self.html.append("<head><title>Student Report : \(studentName) (\(studentID))</title></head>")
    }

    fileprivate func htmlAddBody(forStrudent studentName:String, withID studentID:String) {
        self.html.append("<boby>")
        self.html.append("<h2>Student Report : \(studentName) (\(studentID))</h2>")
        self.html.append(self.generateCheckinTable())
        self.html.append("</boby>")
    }

    fileprivate func generateCheckinTable() -> String {
        var tmpHtml = "<table><tr><th>Student Attendance Records:</th></tr>"

        for checkin in self.db.studentAttendance {
            tmpHtml.append("<tr><td>\(checkin)</td></tr>")
        }

        tmpHtml.append("</table>")

        return tmpHtml
    }
}
