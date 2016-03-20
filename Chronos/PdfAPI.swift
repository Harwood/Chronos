import Foundation
import UIKit

/*
Handles the generation of PDF files
*/
final class PdfAPI {
    static let sharedInstance = PdfAPI()

    private let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

    private init() {} //This prevents others from using the default '()' initializer for this class.

    func createPDF(fromHTML html:String, toFile filename:String) -> String {
        let renderer = self.createRender(withHtml: html)

        self.assignRects(toRenderer: renderer)

        let data = self.createAndDraw(withRenderer: renderer)

        return self.save(pdfData: data, toFile: filename)
    }

    func generateURLRequestForPDF(withName filename:String) -> NSURLRequest {
        let filePath = "\(self.documentsPath)/\(filename).pdf"
        let url = NSURL(fileURLWithPath: filePath)
        let urlRequest = NSURLRequest(URL: url)

        return urlRequest

    }

    private func createRender(withHtml html:String) -> UIPrintPageRenderer {
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(fmt, startingAtPageAtIndex: 0)

        return renderer
    }

    private func assignRects(toRenderer renderer:UIPrintPageRenderer) {
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) //A4, 72 dpi
        let printable = CGRectInset(page, 0, 0)

        renderer.setValue(NSValue(CGRect: page), forKey: "pagerRect")
        renderer.setValue(NSValue(CGRect: printable), forKey: "printableRect")
    }

    private func createAndDraw(withRenderer renderer:UIPrintPageRenderer) -> NSMutableData {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, renderer.printableRect, nil)

        for i in 1...renderer.numberOfPages() {
            UIGraphicsBeginPDFPage()
            let bounds = UIGraphicsGetPDFContextBounds()
            renderer.drawPageAtIndex(i - 1, inRect: bounds)
        }

        UIGraphicsEndPDFContext()

        return pdfData
    }

    private func save(pdfData data:NSMutableData, toFile filename:String) -> String {

        let saveLocation = "\(self.documentsPath)/\(filename).pdf"
        data.writeToFile(saveLocation, atomically: true)

        return saveLocation
    }
}