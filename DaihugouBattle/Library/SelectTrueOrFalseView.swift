//
//  SelectTrueOrFalseView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/06.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

protocol SelectTrueOrFalseDelegate: class{
    func touchUpTrue()
    func touchUpFalse()
}

class SelectTrueOrFalseView: UINibView{
    weak var delegate: SelectTrueOrFalseDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    @IBAction func touchUpTrue(_ sender: UIButton){
        delegate?.touchUpTrue()
    }
    
    @IBAction func touchUpFalse(_ sender: UIButton){
        delegate?.touchUpFalse()
    }
}

