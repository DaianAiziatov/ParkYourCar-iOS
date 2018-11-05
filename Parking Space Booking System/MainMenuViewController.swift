//
//  HomeViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 02/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import MessageUI

class MainMenuViewController: UIViewController {

    private let menuItemsArray = ["Home", "Add New Ticket", "Location", "Report"]
    private let settingItemsArray = ["Update Profile", "Instruction", "Contacts", "Logout"]
    
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: TableView
extension MainMenuViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        } else {
            switch settingItemsArray[indexPath.row] {
            case "Contacts" : contactsPressed()
            case "Logout" : logoutPressed()
            default:
                print(settingItemsArray[indexPath.row])
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Main Menu" : "Settings"
    }
    
    
    // MARK: functions for menu
    private func logoutPressed() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = sb.instantiateViewController(withIdentifier: "loginVC")
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    private func contactsPressed() {
        let alert = UIAlertController(title: "Need help?", message: "Contact us:", preferredStyle: UIAlertController.Style.alert)
        //sending SMS
        alert.addAction(UIAlertAction(title: "SMS", style: .default, handler: sendSMS))
        //sending Email
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: sendEmail))
        //calling for help
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: makeCall))
        //cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeCall(alert: UIAlertAction!) {
        guard let number = URL(string: "tel://" + "1234567743") else { return }
        UIApplication.shared.open(number)
    }
    
    private func sendEmail(alert: UIAlertAction!) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["parking@lambton.com"])
        composeVC.setMessageBody("<p>My question is: </p>", isHTML: true)
        if MFMailComposeViewController.canSendMail() {
            self.present(composeVC, animated: true)
        }
    }
    
    private func sendSMS(alert: UIAlertAction!) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.recipients = ["13142026521"]
        composeVC.body = "My question is:"
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
}

extension MainMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? menuItemsArray.count : settingItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = menuItemsArray[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = settingItemsArray[indexPath.row]
            return cell
        }
    }
    
    
}

// MARK: Message
extension MainMenuViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: Mail
extension MainMenuViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
    
}

