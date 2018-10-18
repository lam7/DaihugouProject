//
//  ZLSwipeableCardView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/09.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
        self.clipsToBounds = true
        
        let contentView = UIView(frame: self.bounds)
        self.addSubview(contentView)
        
        contentView.addSubview(imageView)
        imageView.frame = contentView.frame
        imageView.center = contentView.center
    }
    
    func set(image: UIImage) {
        let rotate = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .left)
        self.imageView.image = rotate
    }
    
}

