//
//  ReportTableViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class ReportTableViewController: UITableViewController {
    
    private var tickets = [ParkingTicket]()
    private var fileteredTicket = [ParkingTicket]()  // for search
    private let searchController = UISearchController(searchResultsController: nil)
    private let storageRef = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // load list from firebase
        loadParkingTickets(completion: {self.tableView.reloadData()})
    }
    
    // MARK: -Load parkingtickets from firebase
    private func loadParkingTickets(completion: @escaping () -> () ) {
        let user = Auth.auth().currentUser!
        let userRef = Database.database().reference()
        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let color = value?["color"] as? String
                let date = value?["date"] as? String
                let manufacturer = value?["manufacturer"] as? String
                let model = value?["model"] as? String
                let payment = value?["payment"] as? String
                let plate = value?["plate"] as? String
                let slotNumber = value?["slotNumber"] as? String
                let spotNumber = value?["spotNumber"] as? String
                let timing = value?["timing"] as? String
                let total = value?["total"] as? Double
                let userEmail = value?["userEmail"] as? String
                self.tickets.append(ParkingTicket(userEmail: userEmail!, carPlate: plate!, carManufacturer: manufacturer!, carModel: model!, carColor: color!, timing: timing!, date: date!, slotNumber: slotNumber!, spotNumber: spotNumber!, paymentMethod: payment!, total: total!))
            }
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: -Load carlogo from firebase
    private func loadCarLogo(manufacturer: String, cellImageView: UIImageView, completion: @escaping () -> () ) {
        let logoRef = storageRef.child("cars_logos/\(manufacturer).png")
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
                        cellImageView.image = image
                    }
                    }.resume()
            }
        }
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "TickeTableViewCell", bundle: nil)
        self.tableView.register(ticketCell, forCellReuseIdentifier: "ticketCell")
    }
    
    // MARK: -Initialization
    private func initialization() {
        self.navigationItem.title = "Report"
        // register custom cell for table and table view preparation
        self.registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        //search controller preparation
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by car plate"
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive == true && searchController.searchBar.text != "" {
            return fileteredTicket.count
        }
        return tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // for search results
        if searchController.isActive == true && searchController.searchBar.text != "" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell {
                cell.manufacturerLabel.text = fileteredTicket[indexPath.row].carManufacturer
                cell.modelLabel.text = fileteredTicket[indexPath.row].carModel
                cell.colorLabel.text = fileteredTicket[indexPath.row].carColor
                cell.plateLabel.text = fileteredTicket[indexPath.row].carPlate
                loadCarLogo(manufacturer: fileteredTicket[indexPath.row].carManufacturer, cellImageView: cell.manufacturerLogo, completion: {print("LOAD")})
                cell.slotLabel.text = fileteredTicket[indexPath.row].slotNumber
                cell.spotLabel.text = fileteredTicket[indexPath.row].spotNumber
                cell.timingLabel.text = fileteredTicket[indexPath.row].timing.description
                cell.totalLabel.text = "$ \(fileteredTicket[indexPath.row].paymentAmount)"
                cell.paymentLogo.image = UIImage(named: "\(fileteredTicket[indexPath.row].paymentMethod.description).png")
                cell.dateLabel.text = fileteredTicket[indexPath.row].date.description
                return cell
            }
        // for original list
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell {
            cell.manufacturerLabel.text = tickets[indexPath.row].carManufacturer
            cell.modelLabel.text = tickets[indexPath.row].carModel
            cell.colorLabel.text = tickets[indexPath.row].carColor
            cell.plateLabel.text = tickets[indexPath.row].carPlate
            loadCarLogo(manufacturer: tickets[indexPath.row].carManufacturer, cellImageView: cell.manufacturerLogo, completion: {print("LOAD")})
            cell.slotLabel.text = tickets[indexPath.row].slotNumber
            cell.spotLabel.text = tickets[indexPath.row].spotNumber
            cell.timingLabel.text = tickets[indexPath.row].timing.description
            cell.totalLabel.text = "$ \(tickets[indexPath.row].paymentAmount)"
            cell.paymentLogo.image = UIImage(named: "\(tickets[indexPath.row].paymentMethod.description).png")
            cell.dateLabel.text = tickets[indexPath.row].date.description
            return cell
        }
        // default
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
        cell.textLabel!.text = tickets[indexPath.row].carManufacturer
        return cell
    }
    
    // MARK: -Design for each cells
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor =
            UIColor.clear
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 10, width: cell.frame.size.width - 20, height: 140))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let receiptVC = sb.instantiateViewController(withIdentifier: "receiptVC") as! ReceiptViewController
        if searchController.isActive == true && searchController.searchBar.text != "" {
            receiptVC.ticket = fileteredTicket[indexPath.row]
        } else {
            receiptVC.ticket = tickets[indexPath.row]
        }
        receiptVC.fromReport = true
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }

}

// MARK: - Searchbar delegate
extension ReportTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchController.searchBar.text
        fileteredTicket = tickets.filter({ (item) -> Bool in
            let value: NSString = item.carPlate as NSString
            return (value.range(of: searchString!, options: .caseInsensitive).location != NSNotFound)
        })
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        tableView.reloadData()
    }
    
}


