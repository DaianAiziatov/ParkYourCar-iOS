//
//  PDFComposer.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 16/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation
import UIKit

class PDFComposer: NSObject {
    
    static let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "invoice", ofType: "html")
    private static let senderInfo = "Park Your Car Inc.<br>123 Somewhere Str.<br>10000 - MyCity<br>MyCountry"
    private static let logoImageURL = "https://firebasestorage.googleapis.com/v0/b/parking-space-booking-system.appspot.com/o/splash_logo.png?alt=media&token=b2addbe8-9fc9-44cd-844d-5f986818fc28"
    static var pdfFilename: String!
    
    override init() {
        super.init()
    }
    
    static func renderInvoice(for ticket: ParkingTicket) -> String! {
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            // Replace all the placeholders with real values except for the items.
            // The logo image.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO_IMAGE#", with: logoImageURL)
            // Invoice date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_DATE#", with: ticket.date.description)
            // Sender info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SENDER_INFO#", with: senderInfo)
            // Recipient info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#RECIPIENT_INFO#", with: ticket.userEmail)
            // Payment method.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PAYMENT_METHOD#", with: ticket.paymentMethod.description)
            // Car.
            let carTitle = "\(ticket.carColor) \(ticket.carManufacturer) \(ticket.carModel) (\(ticket.carPlate))"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CAR#", with: carTitle)
            // Timing.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TIMING#", with: ticket.timing.description)
            // Total amount.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_AMOUNT#", with: "\(ticket.paymentAmount)")
            return HTMLContent
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        return nil
    }
    
    static func exportHTMLContentToPDFAndGetPath(HTMLContent: String) -> URL {
        let printPageRenderer = CustomPrintPageRenderer()
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileURL = documentsDirectory!.appendingPathComponent("ticket.pdf")
        pdfData!.write(to: fileURL, atomically: true)
        return fileURL
    }
    
    static func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        UIGraphicsBeginPDFPage()
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        UIGraphicsEndPDFContext()
        return data
    }
    
    
    
}
