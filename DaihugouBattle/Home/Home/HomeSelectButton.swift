//
//  HomeSelectButton.swift
//  DaihugouBattle
//
//  Created by main on 2019/04/06.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

@IBDesignable class HomeSelectViewButton: ZFRippleButton{
    override var isSelected: Bool{
        didSet{
            let color = isSelected ? selectedBackgroundColor : nonSelectedBackgroundColor
            backgroundColor = color ?? backgroundColor
        }
    }
    
    @IBInspectable var selectedBackgroundColor: UIColor?
    @IBInspectable var nonSelectedBackgroundColor: UIColor?
}
