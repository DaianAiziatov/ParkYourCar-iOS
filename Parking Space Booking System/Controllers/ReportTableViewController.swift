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

    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    // MARK: - Initialization
    private func initialization() {
        self.navigationItem.title = "Report"
        // register custom cell for table and table view preparation
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        // search controller preparation
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by car plate"
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        // load list from firebase
        loadParkingTickets()
    }
    
    private func loadParkingTickets() {
        FirebaseManager.sharedInstance().loadParkingTickets { result in
            switch result {
            case .failure(let error): print("Error ocured while fetching parking tickets: \(error.localizedDescription)")
            case .success(let tickets):
                self.tickets += tickets
                self.tableView.reloadData()
            }
        }
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "TickeTableViewCell", bundle: nil)
        self.tableView.register(ticketCell, forCellReuseIdentifier: "ticketCell")
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell else {
            fatalError("There is no such cell: ticketCell")
        }
        if searchController.isActive == true && searchController.searchBar.text != "" {
            cell.configure(with: fileteredTicket[indexPath.row])
        } else {
            cell.configure(with: tickets[indexPath.row])
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let receiptVC = sb.instantiateViewController(withIdentifier: "receiptVC") as! ReceiptViewController
        if searchController.isActive == true && searchController.searchBar.text != "" {
            receiptVC.ticket = fileteredTicket[indexPath.row]
        } else {
            receiptVC.ticket = tickets[indexPath.row]
        }
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


