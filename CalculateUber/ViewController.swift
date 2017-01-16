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
    
    @IBOutlet weak var blurryView: UIView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let regionRadius: CLLocationDistance = 750
    
    var screenshot = UIImage()
    var tapToCloseNavigation: UITapGestureRecognizer?
    
    var resultSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCurrentLocation()
        createBlurryBackground()
        createTapToCloseNavigation()
        blurryView.isHidden = true
        
    }
    
    @IBAction func onCalculatePressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onRequestUberPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onCurrentLocationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        blurryView.isHidden = false
        
        createNavigationSearchBar(withPlaceholder: "Enter Pickup Location")
    }
    
    @IBAction func onEnterDestinationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        blurryView.isHidden = false
        
        createNavigationSearchBar(withPlaceholder: "Enter Destination")
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
    
    func createBlurryBackground() {

        //create screenshot
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
        screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: screenshot)
        imageView.addBlurEffect()
        blurryView.addSubview(imageView)
    }
    
    func createTapToCloseNavigation() {
        
        tapToCloseNavigation = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideNavigationController))
        blurryView.addGestureRecognizer(tapToCloseNavigation!)
    }
    
    func hideNavigationController() {
        
        self.navigationController?.isNavigationBarHidden = true
        blurryView.isHidden = true
    }
    
    func createNavigationSearchBar(withPlaceholder: String) {
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = withPlaceholder
        navigationItem.titleView = resultSearchController?.searchBar
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
}

extension UIView {
    func addBlurEffect() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
