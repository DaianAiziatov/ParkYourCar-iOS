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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    private func initialization() {
        let actionButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.pdf(sender:)))
        self.navigationItem.rightBarButtonItem = actionButton
        loadCarLogo()
        receiptView.applyZigZagEffect()
        dateLabel.text = ticket.date.description
        manufacturerLabel.text = ticket.carManufacturer
        modelLable.text = ticket.carModel
        colorLabel.text = ticket.carColor
        plateLabel.text = ticket.carPlate
        paymentLabel.text = ticket.paymentMethod.description
        totalLabel.text = "Total: $\(ticket.paymentAmount)"
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
    
    private func loadCarLogo() {
        FirebaseManager.sharedInstance().loadImageURL(for: ticket.carManufacturer) { result in
            switch result {
            case .failure(let error): print("Error occurred while fetching carlogoURL: \(error.localizedDescription)")
            case .success(let url): self.logoImageView.downloaded(from: url, contentMode: .scaleAspectFit)
            }
        }
    }

}

