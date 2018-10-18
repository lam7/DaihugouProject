//
//  CircleGauge.swift
//  Daihugou
//
//  Created by Main on 2017/05/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

class UICircleLabel: UILabel{
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        let radius = frame.width > frame.height ? frame.width : frame.height
        self.baselineAdjustment = .alignCenters
        self.textAlignment = .center
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
