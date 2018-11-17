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
    private var fileteredTicket = [ParkingTicket]()
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Report"
        self.registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        loadParkingTickets(completion: {self.tableView.reloadData()})
//        let searchButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
//        self.navigationItem.rightBarButtonItem = searchButton
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by car plate"
        definesPresentationContext = true
        //self.navigationController!.navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController.searchBar
    }

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
    
    @objc func searchTapped(_ sender: UIBarButtonItem) {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by car plate"
        present(searchController, animated: true, completion: nil)
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "TickeTableViewCell", bundle: nil)
        self.tableView.register(ticketCell, forCellReuseIdentifier: "ticketCell")
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")  {
        fileteredTicket = tickets.filter({ (item) -> Bool in
            let value: NSString = item.carPlate as NSString
            return (value.range(of: searchText, options: .caseInsensitive).location != NSNotFound)
        })
        tableView.reloadData()
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
        if searchController.isActive == true && searchController.searchBar.text != "" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell {
                cell.manufacturerLabel.text = fileteredTicket[indexPath.row].carManufacturer
                cell.modelLabel.text = fileteredTicket[indexPath.row].carModel
                cell.colorLabel.text = fileteredTicket[indexPath.row].carColor
                cell.plateLabel.text = fileteredTicket[indexPath.row].carPlate
                cell.manufacturerLogo.image = UIImage(named: "\(fileteredTicket[indexPath.row].carManufacturer).png")
                cell.slotLabel.text = fileteredTicket[indexPath.row].slotNumber
                cell.spotLabel.text = fileteredTicket[indexPath.row].spotNumber
                cell.timingLabel.text = fileteredTicket[indexPath.row].timing.description
                cell.totalLabel.text = "$ \(fileteredTicket[indexPath.row].paymentAmount)"
                cell.paymentLogo.image = UIImage(named: "\(fileteredTicket[indexPath.row].paymentMethod.description).png")
                cell.dateLabel.text = fileteredTicket[indexPath.row].date.description
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
            cell.textLabel!.text = fileteredTicket[indexPath.row].carManufacturer
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell {
            cell.manufacturerLabel.text = tickets[indexPath.row].carManufacturer
            cell.modelLabel.text = tickets[indexPath.row].carModel
            cell.colorLabel.text = tickets[indexPath.row].carColor
            cell.plateLabel.text = tickets[indexPath.row].carPlate
            cell.manufacturerLogo.image = UIImage(named: "\(tickets[indexPath.row].carManufacturer).png")
            cell.slotLabel.text = tickets[indexPath.row].slotNumber
            cell.spotLabel.text = tickets[indexPath.row].spotNumber
            cell.timingLabel.text = tickets[indexPath.row].timing.description
            cell.totalLabel.text = "$ \(tickets[indexPath.row].paymentAmount)"
            cell.paymentLogo.image = UIImage(named: "\(tickets[indexPath.row].paymentMethod.description).png")
            cell.dateLabel.text = tickets[indexPath.row].date.description
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
        cell.textLabel!.text = tickets[indexPath.row].carManufacturer
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor =
            UIColor.clear
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 10, width: cell.frame.size.width - 20, height: 140))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.5
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
        //tableView.reloadData()
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }

}

extension ReportTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchController.searchBar.text
        fileteredTicket = tickets.filter({ (item) -> Bool in
            let value: NSString = item.carPlate as NSString
            return (value.range(of: searchString!, options: .caseInsensitive).location != NSNotFound)
        })
        tableView.reloadData()
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        tableView.reloadData()
//    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        tableView.reloadData()
    }
    
}

extension ReportTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
}
