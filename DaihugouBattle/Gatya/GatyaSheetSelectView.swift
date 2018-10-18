//
//  GatyaSheetSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GatyaSheetSelectView: UIView{
    var segueIdentifier: String!
    var possession: Int!
    var consume: Int!
    var consumeType: String!
    var id: Int!
    var max: Int{
        var count: Int = possession / consume
        return count >= 10 ? 10 : count
    }
    var numOfSheet: Int{
        return current
    }
    private var current: Int = 1
    private var view: UIView!
    @IBOutlet private weak var sheetCountLabel: UILabel!
    @IBOutlet private weak var possessionLabel: UILabel!

    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    private func loadNib() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func setUp(){
        updateLabel()
        possessionLabel.text = possession.description
    }
    
    private func loadViewFromNib() -> UIView {
        return Bundle(for: type(of: self)).loadNibNamed("GatyaSheetSelectView", owner: self, options: nil)?.first as! UIView
    }
    
    @IBAction func regulationSheet(_ sender: UIButton){
        switch sender.tag{
        case 1:
            current -= 1
            if current < 1{ current = 1 }
        case 2:
            current += 1
            if current > max{ current = max }
        case 3:
            current = max
        default:
            break
        }
        updateLabel()
    }
    
    @IBAction func buy(_ sender: UIButton) {
        self.parentViewController()?.performSegue(withIdentifier: segueIdentifier, sender: self.parentViewController())
        self.isHidden = true
    }
    
    @IBAction func back(_ sender : UIButton){
        self.isHidden = true
    }
    
    private func updateLabel(){
        sheetCountLabel.text = current.description
    }
    
    
}
