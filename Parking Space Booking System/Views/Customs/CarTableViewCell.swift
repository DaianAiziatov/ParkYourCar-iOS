//
//  CarTableViewCell.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 14/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with car: Car) {
        let title = "\(car.color) \(car.manufacturer) \(car.model ?? "")"
        titleLabel?.text = title
        plateLabel?.text = "\(car.plateNumber)"
        FirebaseManager.sharedInstance().loadImageURL(for: car.manufacturer) { result in
            switch result {
            case .failure(let error): print("Error occured while fetching logo url: \(error.localizedDescription)")
            case .success(let url): self.logoImageView.downloaded(from: url, contentMode: .scaleAspectFit)
            }
        }
    }
    
}
