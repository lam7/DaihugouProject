//
//  RoundCornerButton.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundCornerButton: UIButton{
    @IBInspectable var highlightedBackgroundColor :UIColor?
    @IBInspectable var nonHighlightedBackgroundColor :UIColor?
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0
    
    override open var isSelected: Bool{
        didSet {
            if isSelected {
                self.backgroundColor = highlightedBackgroundColor
            }
            else {
                self.backgroundColor = nonHighlightedBackgroundColor
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let size = min(bounds.size.height, bounds.size.width)

        self.layer.cornerRadius = cornerRadius == 0 ? size / 2 : cornerRadius
        self.layer.borderColor  = borderColor.cgColor
        self.layer.borderWidth  = borderWidth
        self.layer.backgroundColor = backgroundColor?.cgColor
        super.draw(rect)
    }
}
