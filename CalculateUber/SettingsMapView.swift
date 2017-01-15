//
//  SettingsMapView.swift
//  CalculateUber
//
//  Created by Vu Dang on 1/15/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

import UIKit
import MapKit

class SettingsMapView: MKMapView {

    override func awakeFromNib() {
        
        showsUserLocation = true
    }

}
