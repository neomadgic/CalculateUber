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

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var mapView: SettingsMapView!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var fromTableView: UITableView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let regionRadius: CLLocationDistance = 750
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fromTableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCurrentLocation()
    }
    
    @IBAction func onCalculatePressed(_ sender: Any) {
        
    }
    
    @IBAction func onRequestUberPressed(_ sender: Any) {
        
    }
    
    func setCurrentLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        guard locationManager.location != nil else {
            print("Can't find location")
            printErrorAlert()
            return
        }
        currentLocation = locationManager.location!
        print(currentLocation.coordinate)
        centerMapOnLocation(location: currentLocation)
    }
    
    func printErrorAlert() {
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings in order for CalculateUber to set your starting location", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return ResultCell()
    }
}

