//
//  BattleSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit

@IBDesignable class BattleSelectView: UIView {
    private var view: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
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
        return Bundle(for: type(of: self)).loadNibNamed("BattleSelectView", owner: self, options: nil)?.first as! UIView
    }

    @IBAction func touchUp(_ sender: UIButton) {
        self.parentViewController()?.performSegue(withIdentifier: "battle", sender: self.parentViewController())
    }
    
}
