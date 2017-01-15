//
//  ViewController.swift
//  CalculateUber
//
//  Created by Vu Dang on 1/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCurrentLocation()
    }
    
    @IBAction func onCalculatePressed(_ sender: Any) {
        
    }
    
    @IBAction func onRequestUberPressed(_ sender: Any) {
        
    }
    
    func setCurrentLocation() {
        
        guard locationManager.location != nil else {
            print("Can't find location")
            printErrorAlert()
            return
        }
        currentLocation = locationManager.location!
        print(currentLocation.coordinate)
    }
    
    func printErrorAlert() {
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings in order for CalculateUber to set your starting location", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
}
