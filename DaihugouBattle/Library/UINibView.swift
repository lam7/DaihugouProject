//
//  UINibView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/13.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class UINibView: UIView, Nibable{
    weak var nibView: UIView!
    var nibName: String{
        return className
    }
    override var backgroundColor: UIColor?{
        didSet{
            guard let nibView = self.nibView else{
                return
            }
            nibView.backgroundColor = backgroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib(nibName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib(nibName)
    }
}

protocol Nibable: class where Self: UIView{
    var nibView: UIView!{ get set }
    func loadNib(_ className: String?)
}

extension Nibable{
    func loadNib(_ className: String?){
        let nibName = className ?? self.className
        nibView = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)?.first as! UIView
        
        // use bounds not frame or it'll be offset
        nibView.frame = bounds
        
        // Make the view stretch with containing view
        nibView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(nibView)
    }
}
