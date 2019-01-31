//
//  TickeTableViewCell.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

class TickeTableViewCell: UITableViewCell {

    @IBOutlet weak var manufacturerLogo: UIImageView!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var spotLabel: UILabel!
    @IBOutlet weak var slotLabel: UILabel!
    @IBOutlet weak var paymentLogo: UIImageView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var ticket: ParkingTicket!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clear
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 10, width: self.frame.size.width - 20, height: 140))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        contentView.addSubview(whiteRoundedView)
        contentView.sendSubviewToBack(whiteRoundedView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func configure(with ticket: ParkingTicket) {
        self.ticket = ticket
        manufacturerLabel.text = ticket.carManufacturer
        modelLabel.text = ticket.carModel
        colorLabel.text = ticket.carColor
        plateLabel.text = ticket.carPlate
        FirebaseManager.sharedInstance().loadImageURL(for: ticket.carManufacturer) { result in
            switch result {
            case .failure(let error): print("Error occured while fetching logo url: \(error.localizedDescription)")
            case .success(let url): self.manufacturerLogo.downloaded(from: url, contentMode: .scaleAspectFit)
            }
        }
        slotLabel.text = ticket.slotNumber
        spotLabel.text = ticket.spotNumber
        timingLabel.text = ticket.timing.description
        totalLabel.text = "$ \(ticket.paymentAmount)"
        paymentLogo.image = UIImage(named: "\(ticket.paymentMethod.description).png")
        dateLabel.text = ticket.date.description
    }
    
}
