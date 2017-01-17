//
//  UIView+Extension.swift
//  CalculateUber
//
//  Created by Vu Dang on 1/17/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addBlurEffect() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
