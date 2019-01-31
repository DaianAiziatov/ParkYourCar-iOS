//
//  HomeViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import KeychainAccess

class HomeViewController: UIViewController, AlertDisplayable {

    @IBOutlet weak var carsListTableView: UITableView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var ticketsTotlaLabel: UILabel!
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    private var numberOftickets: Int? {
        didSet {
            self.ticketsTotlaLabel.text = "Tickets total: \(self.numberOftickets!)"
        }
    }
    private var cars = [Car]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        self.registerTableViewCells()
        let keychain = Keychain(service: "com.lambton.Parking-Space-Booking-System-Group4")
        FirebaseManager.sharedInstance().getUserInfo { result in
            switch result {
            case .failure(let error): print("Error occurred while fetching user info from firebase: \(error.localizedDescription)")
            case .success(let appuser): self.userEmailLabel.text = "User email: \(appuser.email ?? "")"
            }
        }
        lastLoginLabel.text = "Last login: \(keychain["logdate"] ?? "")"
        carsListTableView.delegate = self
        carsListTableView.dataSource = self
        
        let updateButton = UIButton(type: .custom)
        updateButton.setImage(UIImage(named: "update.png"), for: .normal)
        updateButton.addTarget(self, action: #selector(self.updateProfie(sender:)), for: .touchUpInside)
        //updateButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let updateBarButton = UIBarButtonItem(customView: updateButton)
//        updateBarButton.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        updateBarButton.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let contactsButton = UIButton(type: .custom)
        contactsButton.setImage(UIImage(named: "help.png"), for: .normal)
        contactsButton.addTarget(self, action: #selector(self.contacts(sender:)), for: .touchUpInside)
        //contactsButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let contactsBarButton = UIBarButtonItem(customView: contactsButton)
//        contactsBarButton.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        contactsBarButton.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
//
        self.navigationItem.rightBarButtonItems = [updateBarButton, contactsBarButton]
        
        let logoutButton = UIButton(type: .custom)
        logoutButton.setImage(UIImage(named: "logout.png"), for: .normal)
        logoutButton.addTarget(self, action: #selector(self.logoutPressed(sender:)), for: .touchUpInside)
        //logoutButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let logoutBarButton = UIBarButtonItem(customView: logoutButton)
//        logoutBarButton.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        logoutBarButton.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.navigationItem.leftBarButtonItem = logoutBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cars = [Car]()
        loadCarsList()
    }
    
    @objc func contacts(sender: UIBarButtonItem) {
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
        guard let number = URL(string: "telprompt://" + "1234567743") else { return }
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
    
    @objc func logoutPressed(sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.setValue("", forKey: "logDate")
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func updateProfie(sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let updateVC = sb.instantiateViewController(withIdentifier: "updateVC")
        navigationController?.pushViewController(updateVC, animated: true)
    }
    
    @objc private func addTapped() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let addcarVC = sb.instantiateViewController(withIdentifier: "addcarVC")
        navigationController?.pushViewController(addcarVC, animated: true)
    }
    
    private func loadNumberOfParkingTickets() {
        FirebaseManager.sharedInstance().loadParkingTickets { result in
            switch result {
            case .failure(let error): print("Error occured while fetching cars from firebase: \(error.localizedDescription)")
            case .success(let tickets): self.numberOftickets = tickets.count
            }
        }
    }
    
    private func loadCarsList() {
        FirebaseManager.sharedInstance().loadCars { result in
            switch result {
            case .failure(let error): self.displayAlert(with: "Error", message: error.localizedDescription)
            case .success(let cars):
                self.cars += cars
                self.carsListTableView.reloadData()
            }
        }
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "CarTableViewCell", bundle: nil)
        self.carsListTableView.register(ticketCell, forCellReuseIdentifier: "carCell")
    }
}

// MARK: -TableView Delegate
extension HomeViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = #colorLiteral(red: 0.8894551079, green: 0.2323677188, blue: 0.1950711468, alpha: 1)
        let text = UIBarButtonItem(title: "Cars:", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        text.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.init(name: "DIN Alternate", size: 17.0)!,
            NSAttributedString.Key.foregroundColor : UIColor.black], for: UIControl.State.normal)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
        addButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        toolbar.setItems([text, flexibleSpace ,addButton], animated: true)
        return toolbar
    }
    
    
}

// MARK: -TableView DataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirm = UIAlertAction(title: "Confirm", style: .default, handler: ({ action in
                FirebaseManager.sharedInstance().deleteCar(with: self.cars[indexPath.row].carId!) { error in
                    if let error = error {
                        print("Error occured while deleting car from firebase: \(error.localizedDescription)")
                    } else {
                        self.cars.remove(at: indexPath.row)
                        self.carsListTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }))
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            displayAlert(with: "Are you sure to delete this car?", message: "This action can't be undone", actions: [confirm, cancel])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath) as? CarTableViewCell  else {
            fatalError("No cell with id carCell")
        }
        cell.configure(with: cars[indexPath.row])
        return cell
    }
    
}

// MARK: - Message Delegate
extension HomeViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - Mail Delegate
extension HomeViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
    
}
