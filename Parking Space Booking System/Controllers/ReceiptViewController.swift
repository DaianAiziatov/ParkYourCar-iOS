//
//  ReceiptViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 16/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import PDFKit

class ReceiptViewController: UIViewController {

    @IBOutlet weak var receiptView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLable: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // Fetch data from previous screen
    var ticket: ParkingTicket!
    var fromReport = false
    private let storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    private func initialization() {
        self.navigationItem.hidesBackButton = true
        let backToMenuButton = UIBarButtonItem(title: "Back to menu", style: .plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = backToMenuButton
        let actionButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.pdf(sender:)))
        self.navigationItem.rightBarButtonItem = actionButton
        if fromReport {
            self.navigationItem.leftBarButtonItem?.title = "Back to report"
        }
        applyZigZagEffect(givenView: receiptView)
        dateLabel.text = ticket.date.description
        manufacturerLabel.text = ticket.carManufacturer
        modelLable.text = ticket.carModel
        colorLabel.text = ticket.carColor
        plateLabel.text = ticket.carPlate
        paymentLabel.text = ticket.paymentMethod.description
        totalLabel.text = "Totla: $\(ticket.paymentAmount)"
        loadCarLogo {
            print("load")
        }
    }
    
    //generate pdf and share function
    @objc func pdf(sender: UIBarButtonItem) {
        if let ticketHTML = PDFComposer.renderInvoice(for: ticket!) {
            if let document = PDFDocument(url: PDFComposer.exportHTMLContentToPDFAndGetPath(HTMLContent: ticketHTML)) {
                guard let data = document.dataRepresentation() else { return }
                let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
        }
    }

    //back button depends on from which screen user came
    @objc func back(sender: UIBarButtonItem) {
        if !fromReport {
            for vc in (self.navigationController?.viewControllers ?? []) {
                if vc is MainMenuTableViewController {
                    _ = self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    private func loadCarLogo(completion: @escaping () -> () ) {
        let logoRef = storageRef.child("cars_logos/\(ticket.carManufacturer ).png")
        logoRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() {
                        self.logoImageView.image = image
                    }
                    }.resume()
            }
        }
    }
    

    //zigzag corners for ticket view
    private func applyZigZagEffect(givenView: UIView) {
        let width = givenView.frame.size.width
        let height = givenView.frame.size.height
        
        let givenFrame = givenView.frame
        let zigZagWidth = CGFloat(7)
        let zigZagHeight = CGFloat(5)
        var yInitial = height-zigZagHeight
        
        let zigZagPath = UIBezierPath(rect: givenFrame)
        zigZagPath.move(to: CGPoint(x:0, y:0))
        zigZagPath.addLine(to: CGPoint(x:0, y:yInitial))
        
        var slope = -1
        var x = CGFloat(0)
        var i = 0
        while x < width {
            x = zigZagWidth * CGFloat(i)
            let p = zigZagHeight * CGFloat(slope)
            let y = yInitial + p
            let point = CGPoint(x: x, y: y)
            zigZagPath.addLine(to: point)
            slope = slope*(-1)
            i += 1
        }
        
        zigZagPath.addLine(to: CGPoint(x:width,y: 0))
        
        yInitial = 0 + zigZagHeight
        x = CGFloat(width)
        i = 0
        while x > 0 {
            x = width - (zigZagWidth * CGFloat(i))
            let p = zigZagHeight * CGFloat(slope)
            let y = yInitial + p
            let point = CGPoint(x: x, y: y)
            zigZagPath.addLine(to: point)
            slope = slope*(-1)
            i += 1
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = zigZagPath.cgPath
        givenView.layer.mask = shapeLayer
    }

}

