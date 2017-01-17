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


protocol HandleMapSearch {

    func dropPin(placemark:MKPlacemark)
}


class ViewController: UIViewController, UITableViewDelegate, MKMapViewDelegate{
    
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
    
    var endingPin:MKPlacemark? = nil
    var endingAnnotation = MKPointAnnotation()
    
    var startingPin: MKPlacemark? = nil
    var startingAnnotation = MKPointAnnotation()
    
    var isDestinationSearch = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        createLocationSearchTableSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setCurrentLocation()
        createBlurryBackground()
        createTapToCloseNavigation()
        blurryView.isHidden = true
        
    }
    
    @IBAction func onCalculatePressed(_ sender: Any) {
        
        guard startingPin != nil, endingPin != nil else {
            printErrorAlert(with: alertError.emptySearchButton, message: alertError.emptySearchMessage)
            return
        }
        drawDirection()
    }
    
    @IBAction func onRequestUberPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onCurrentLocationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        blurryView.isHidden = false
        
        createNavigationSearchBar(withPlaceholder: "Enter Pickup Location")
        isDestinationSearch = false
    }
    
    @IBAction func onEnterDestinationPressed(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        blurryView.isHidden = false
        
        createNavigationSearchBar(withPlaceholder: "Enter Destination")
        isDestinationSearch = true
    }
    
    
    func setCurrentLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        guard locationManager.location != nil else {
            print("Can't find location")
            printErrorAlert(with: alertError.unableToFindLocation, message: alertError.locationMessage)
            return
        }
        currentLocation = locationManager.location!
        print(currentLocation.coordinate)
        centerMapOnLocation(location: currentLocation)
        startingPin = MKPlacemark(coordinate: currentLocation.coordinate)
    }
    
    func printErrorAlert(with: String, message: String) {
        
        let alert = UIAlertController(title: with, message: message, preferredStyle: .alert)
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
    
    func createLocationSearchTableSettings() {
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func hideNavigationController() {
        
        self.navigationController?.isNavigationBarHidden = true
        blurryView.isHidden = true
    }
    
    func createNavigationSearchBar(withPlaceholder: String) {
        
        let searchBar = resultSearchController!.searchBar
        searchBar.text = ""
        searchBar.sizeToFit()
        searchBar.placeholder = withPlaceholder
        navigationItem.titleView = resultSearchController?.searchBar
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(0x89A12F)
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func drawDirection() {
        
        mapView.removeOverlays(mapView.overlays)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: startingPin!)
        directionRequest.destination = MKMapItem(placemark: endingPin!)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
}

extension ViewController: HandleMapSearch {
    
    func dropPin(placemark: MKPlacemark) {
        
        if isDestinationSearch == true {
            
            // cache the pin
            endingPin = placemark
            // clear existing pins
            mapView.removeAnnotation(endingAnnotation)
            
            // create new annotation and add onto the map
            endingAnnotation.coordinate = placemark.coordinate
            endingAnnotation.title = placemark.name
            if let city = placemark.locality,
                let state = placemark.administrativeArea {
                endingAnnotation.subtitle = "\(city) \(state)"
            }
            mapView.addAnnotation(endingAnnotation)

            //change button label
            enterDestinationButton.setTitle("    \(placemark.name!)", for: .normal)
            enterDestinationButton.setTitleColor(UIColor.black, for: .normal)
        }
        else {
            
            // cache the pin
            startingPin = placemark
            
            // clear existing pins
            mapView.removeAnnotation(startingAnnotation)
            
            //create new annotation and add onto the map
            startingAnnotation.coordinate = placemark.coordinate
            startingAnnotation.title = placemark.name
            if let city = placemark.locality,
                let state = placemark.administrativeArea {
                startingAnnotation.subtitle = "\(city) \(state)"
            }
            mapView.addAnnotation(startingAnnotation)
            
            //change button label
            currentLocationButton.setTitle("    \(placemark.name!)", for: .normal)
            currentLocationButton.setTitleColor(UIColor.black, for: .normal)
        }
        
        //set mapview range
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        hideNavigationController()
    }
}
