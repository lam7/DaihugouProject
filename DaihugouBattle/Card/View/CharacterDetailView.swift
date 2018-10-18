//
//  CharacterDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/16.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CharacterDetailView: UINibView{
    private var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var atkLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var indexLabel: UILabel!
    
    func set(card: Card){
        imageView.image = card.image
        nameLabel.text = card.name
        hpLabel.text = "体力 " + card.hp.description
        atkLabel.text = "攻撃力 " + card.atk.description
        indexLabel.text = "インデックス " + card.index.description
        descriptionTextView.text = "レアリティ " + card.rarity.rawValue + "  \(card.skill.description)"
    }
}

