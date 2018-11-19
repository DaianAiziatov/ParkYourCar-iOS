//
//  LocationViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 11/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private let regionRadius: CLLocationDistance = 100
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Location"
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1: mapView.mapType = .hybrid
        case 2: mapView.mapType = .satellite
        default: mapView.mapType = .standard
        }
    }
    

}

// MARK: -LocationManager Delegate
extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            self.mapView.setRegion(region, animated: true)
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = locValue
            annotation.title = "You are here"
            mapView.addAnnotation(annotation)
        }
    }
}
