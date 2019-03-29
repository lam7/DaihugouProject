//
//  SelectableView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/16.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit


protocol SelectableView{
    var displayView: UIView?{get set}
    func clearView()
}

extension SelectableView{
    func clearView(){
        displayView?.removeSafelyFromSuperview()
    }
}
