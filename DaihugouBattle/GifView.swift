//
//  GifView.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/08.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit


class GifView: UIView{
    weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setUp(){
        let imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        self.imageView = imageView
    }
}


class GifImageView: UIImageView{
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.lighten)
        super.draw(rect)
        UIGraphicsEndImageContext()
    }
}
