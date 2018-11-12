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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
