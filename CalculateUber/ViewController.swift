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
    
    @IBOutlet weak var currentLocationButton: LocationButton!
    @IBOutlet weak var enterDestinationButton: LocationButton!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let regionRadius: CLLocationDistance = 750
    
    var resultSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCurrentLocation()
    }
    
    @IBAction func onCalculatePressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onRequestUberPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onCurrentLocationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onEnterDestinationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
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
