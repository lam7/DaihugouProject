//
//  CharacterStatusDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/07.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CharacterStatusDetailView: UINibView{
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var atkLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var card: Card!{
        didSet{
            nameLabel.text = card.name
            hpLabel.text = card.hp.description
            atkLabel.text = card.atk.description
            indexLabel.text = card.index.description
            let text = card.skills.map{ $0.description }.reduce("", { $0 + $1 + "\n"})
            descriptionTextView.text = "レアリティ " + card.rarity.rawValue + "\n" + text
        }
    }
    @IBInspectable var descriptionTextColor: UIColor = .black{
        didSet{
            hpLabel.textColor = descriptionTextColor
            atkLabel.textColor = descriptionTextColor
            indexLabel.textColor = descriptionTextColor
            nameLabel.textColor = descriptionTextColor
            descriptionTextView.textColor = descriptionTextColor
        }
    }
}
