
//
//  CardSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit

@IBDesignable class CardSelectView: UIView {
    var view: UIView!
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    

    
    @IBAction func touchUp(_ sender: UIButton) {
        let viewController = self.parentViewController()
        
        switch sender.tag{
        case 1:
            viewController?.performSegue(withIdentifier: "deckForming", sender: viewController)
        case 2:
            viewController?.performSegue(withIdentifier: "possessionCard", sender: viewController)
        default:
            break
        }
    }
    
    func loadNib() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return Bundle(for: type(of: self)).loadNibNamed("CardSelectView", owner: self, options: nil)?.first as! UIView
    }
}
