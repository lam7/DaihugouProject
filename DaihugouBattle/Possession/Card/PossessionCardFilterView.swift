//
//  PossessionCardFilterView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/03.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PossessionCardFilterView: UIView{
    @IBOutlet var indexButtons: [RoundCornerButton]!
    private var indexFlag = [Bool](repeating: false, count: AbsolutelyUsedNumber.count)
    private var rarityFlag = [Bool](repeating: false, count: Rarity.count)
    private var view: UIView!
    var apply: ((_ indexs: [Int], _ rarities: [Rarity]) -> ())!
    private var indexs: [Int]{
        var r: [Int] = []
        for (index, flag) in indexFlag.enumerated(){
            if flag{
                r.append(index + 1)
            }
        }
        return r
    }
    private var rarities: [Rarity]{
        var r:[Rarity] = []
        if rarityFlag[0]{
            r.append(.UR)
        }
        if rarityFlag[1]{
            r.append(.SR)
        }
        if rarityFlag[2]{
            r.append(.R)
        }
        if rarityFlag[3]{
            r.append(.N)
        }
        return r
    }
    
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
    
    private func loadViewFromNib() -> UIView {
        return Bundle(for: type(of: self)).loadNibNamed("PossessionCardFilterView", owner: self, options: nil)?.first as! UIView
    }
    
    @IBAction func indexTouchUp(_ sender: UIButton) {
        if sender.tag == 99{
            if sender.isSelected{
                return
            }
            let flag = !indexFlag.filter({ $0 }).isEmpty
            indexFlag = [Bool](repeating: flag, count: indexFlag.count)
            self.indexButtons.forEach{ $0.isSelected = false }
            sender.isSelected = true
            
        }else if indexFlag.inRange(sender.tag - 1){
            indexButtons[0].isSelected = false
            indexFlag[sender.tag - 1] = !indexFlag[sender.tag - 1]
            sender.isSelected = indexFlag[sender.tag - 1]
            print(sender.tag - 1)
            print(indexFlag[sender.tag - 1])
        }
        applyFilter()
    }
    @IBAction func rarityTouchUp(_ sender: UIButton) {
        if !rarityFlag.inRange(sender.tag - 1){
            print("Out of range rarityFlag tag: \(sender.tag)")
            return
        }
        rarityFlag[sender.tag - 1] = !rarityFlag[sender.tag - 1]
        sender.isSelected = rarityFlag[sender.tag - 1]
        applyFilter()
    }
    
    private func createImage(from color: UIColor)-> UIImage{
        let rect = CGRect(x: 0 ,y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func applyFilter(){
        apply(indexs, rarities)
    }

    @IBAction func closeTouchUp(_ sender: UIButton) {
        self.isHidden = true
        applyFilter()
    }
}
