//
//  DeckSelectPageView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/17.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

protocol DeckSelectPageViewDelegate: class{
    func selectButtonAction(_ sender: UIButton)
}

class DeckSelectPageView: UINibView{
    @IBOutlet weak var selectButton0: UIButton!
    @IBOutlet weak var selectButton1: UIButton!
    @IBOutlet weak var selectButton2: UIButton!
    @IBOutlet weak var selectButton3: UIButton!
    @IBOutlet weak var selectButton4: UIButton!
    @IBOutlet weak var selectButton5: UIButton!
    @IBOutlet weak var selectButton6: UIButton!
    @IBOutlet weak var selectButton7: UIButton!
    @IBOutlet weak var selectButton8: UIButton!
    var selectButtons: [UIButton]{
        return [
            selectButton0, selectButton1, selectButton2,
            selectButton3, selectButton4, selectButton5,
            selectButton6, selectButton7, selectButton8,
        ]
    }
    weak var delegate: DeckSelectPageViewDelegate?
    
    
    @IBAction func touchUp(_ sender: UIButton){
        delegate?.selectButtonAction(sender)
    }
    
}
