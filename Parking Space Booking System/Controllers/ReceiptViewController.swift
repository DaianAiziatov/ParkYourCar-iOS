//
//  ReceiptViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 16/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

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
    
    var ticket: ParkingTicket!
    var fromReport = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let backToMenuButton = UIBarButtonItem(title: "Back to menu", style: .plain, target: self, action: #selector(self.backToMenu(sender:)))
        self.navigationItem.leftBarButtonItem = backToMenuButton
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
        totalLabel.text = "Totla: \(ticket.paymentAmount)"
        logoImageView.image = UIImage(named: "\(ticket.carManufacturer).png")
    }
    
    @objc func backToMenu(sender: UIBarButtonItem) {
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
