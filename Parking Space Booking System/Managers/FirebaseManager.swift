//
//  FirebaseManager.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    
    private static var instance: FirebaseManager?
    
    private let storageRef: StorageReference
    private let auth: Auth
    private let userRef: DatabaseReference
    private lazy var user = {
        return Auth.auth().currentUser!
    }()
    
    private init() {
        storageRef = Storage.storage().reference()
        userRef = Database.database().reference()
        auth = Auth.auth()
    }
    
    static func sharedInstance() -> FirebaseManager {
        if instance != nil {
            return instance!
        } else {
            return FirebaseManager()
        }
    }
    
    //  MARK: - Login
    func login(with email: String, password: String, completion: @escaping (Error?) -> ()) {
        auth.signIn(withEmail: email, password: password) {
            (user, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(appuser: AppUser, with password: String, completion: @escaping (Error?) -> ()) {
        //creating user for firebase auth
        auth.createUser(withEmail: appuser.email!, password: password) { (user, error) in
            if let error = error {
                completion(error)
            } else {
                let user = Auth.auth().currentUser!
                let userName = appuser.firstName
                let userSurname = appuser.lastName
                let contactNumber = appuser.contactNumber
                //adding user to realtime database
                self.userRef.child("users").child(user.uid).setValue(
                        ["firstName": "\(userName)",
                        "lastName": "\(userSurname)",
                        "email": "\(appuser.email ?? "")",
                        "contactNumber": "\(contactNumber)"])
                completion(nil)
            }
        }
    }
    
    // MARK: - Update info
    func updateInfo(with appuser: AppUser, completion: @escaping (Error?) -> ()) {
        let key = userRef.child("users").child(user.uid).key
        //user
        let userName = appuser.firstName
        let userSurname = appuser.lastName
        let contactNumber = appuser.contactNumber
        //car
        let userData = ["firstName": "\(userName)",
            "lastName": "\(userSurname)",
            "email": "\(user.email ?? "")",
            "contactNumber": "\(contactNumber)"] as [String : Any]
        userRef.child("users/\(key!)").updateChildValues(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
        
    }
    
    // MARK: - Get user info
    func getUserInfo(completion: @escaping (Result<AppUser, NSError>) -> ()) {
        userRef.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let contactNumber = value?["contactNumber"] as? String ?? ""
            let appuser = AppUser(firstName: firstName, lastName: lastName, email: self.user.email, contactNumber: contactNumber)
            completion(Result.success(appuser))
        }) { (error) in
            completion(Result.failure(error as NSError))
        }
    }
    
    // MARK: - Update password
    func update(oldPassword: String, with newPassword: String, completion: @escaping (Error?) -> ()) {
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)
        user.reauthenticateAndRetrieveData(with: credential, completion: { (autDataResult, error) in
            if let error = error {
                completion(error)
            } else {
                self.user.updatePassword(to: newPassword)
                completion(nil)
        }})
    }
 
    // MARK: - Load image URL
    func loadImageURL(for manufacturer: String, completion: @escaping (Result<URL, NSError>) -> ()) {
        let logoRef = storageRef.child("cars_logos/\(manufacturer).png")
        logoRef.downloadURL { url, error in
            if let error = error {
                completion(Result.failure(error as NSError))
            } else {
                completion(Result.success(url!))
            }
        }
    }
    
    // MARK: - Load parking tickets
    func loadParkingTickets(completion: @escaping (Result<[ParkingTicket], NSError>) -> () ) {
        var tickets = [ParkingTicket]()
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
                tickets.append(ParkingTicket(userEmail: userEmail!, carPlate: plate!, carManufacturer: manufacturer!, carModel: model!, carColor: color!, timing: timing!, date: date!, slotNumber: slotNumber!, spotNumber: spotNumber!, paymentMethod: payment!, total: total!))
            }
            completion(Result.success(tickets))
        }) { (error) in
            completion(Result.failure(error as NSError))
        }
    }
    
    // MARK: - Save ticket
    func save(ticket: ParkingTicket, completion: @escaping (Error?) -> ()) {
        let ticketsRef = userRef.child("users").child(user.uid).child("tickets").childByAutoId()
        let email = ticket.userEmail
        let manufacturerName = ticket.carManufacturer
        let modelName = ticket.carModel
        let plateNumber = ticket.carPlate
        let color = ticket.carColor
        let timing = ticket.timing
        let slotNumber = ticket.slotNumber
        let spotNumber = ticket.spotNumber
        let payment = ticket.paymentMethod
        let total = ticket.paymentAmount
        let userData =
            ["userEmail" : "\(email)",
                "manufacturer": "\(manufacturerName)",
                "model": "\(modelName)",
                "plate": "\(plateNumber)",
                "color": "\(color)",
                "date": "\(Date.currentDate())",
                "timing": "\(timing)",
                "slotNumber": "\(slotNumber)",
                "spotNumber": "\(spotNumber)",
                "payment": "\(payment)",
                "total": total
                ] as Any
        ticketsRef.setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Load Cars
    func loadCars(completion: @escaping (Result<[Car], NSError>) -> () ) {
        var cars = [Car]()
        userRef.child("users").child(user.uid).child("cars").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let id = rest.key
                let color = value?["color"] as? String
                let manufacturer = value?["manufacturer"] as? String
                let model = value?["model"] as? String
                let plate = value?["plate"] as? String
                let car = Car(carID: id, manufacturerName: manufacturer!, modelName: model!, plateNumber: plate!, color: color!)
                cars.append(car)
            }
            completion(Result.success(cars))
        }) { (error) in
            completion(Result.failure(error as NSError))
        }
    }
    
    // MARK: - Add new car
    func add(new car: Car, completion: @escaping (Error?) -> ()) {
        let carsRef = userRef.child("users").child(user.uid).child("cars").childByAutoId()

        let manufacturerName = car.manufacturer
        let modelName = car.model
        let plateNumber = car.plateNumber
        let color = car.color
        let userData =
            ["manufacturer" : "\(manufacturerName)",
                "model": "\(modelName!)",
                "plate": "\(plateNumber)",
                "color": "\(color)"] as Any
        carsRef.setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Delete car
    func deleteCar(with id: String, completion: @escaping (Error?) -> ()) {
        userRef.child("users").child(self.user.uid).child("cars").child(id).removeValue { error, dbref  in
            if error == nil {
                completion(nil)
            } else {
                completion(error)
            }
        }
    }
    
    // MARK: - Load colors list
    func loadColorsList(completion: @escaping (Result<[String], NSError>) -> ()) {
        userRef.child("colors").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let colors = (value?["colors"] as? String)?.components(separatedBy: .punctuationCharacters)
            completion(Result.success(colors!))
        }) { (error) in
            completion(Result.failure(error as NSError))
        }
    }
    
    // MARK: - Load models list
    func loadModelsList(completion: @escaping (Result<[String: Manufacturer], NSError>) -> ()) {
        userRef.child("cars_models").observeSingleEvent(of: .value, with: { (snapshot) in
            var manufacturersDictionary = [String: Manufacturer]()
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let company = value?["name"] as? String
                var models = ["Models"]
                models += ((value?["models"] as? String)?.components(separatedBy: .punctuationCharacters))!
                manufacturersDictionary[company!] = Manufacturer(name: company!, models: models)
            }
            completion(Result.success(manufacturersDictionary))
        }) { (error) in
            completion(Result.failure(error as NSError))
        }
    }
}
