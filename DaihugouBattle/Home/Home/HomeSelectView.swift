//
//  HomeSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class HomeSelectView: UINibView, SelectableView {
    weak var displayView: UIView?{
        didSet{
            oldValue?.removeSafelyFromSuperview()
        }
    }
    @IBAction func gift(_ sender: UIButton){
        let giftView = GiftBoxView(frame: bounds)
        addSubview(giftView)
        UIView.animateOpenWindow(giftView)
        giftView.updateInfosReceived()
        displayView = giftView
    }
    
    @IBAction func present(_ sender: UIButton){
        let debug = Debug_GiftItemView(frame: bounds)
        addSubview(debug)
        UIView.animateOpenWindow(debug)
        displayView = debug
    }
}
