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
        hpLabel.text = card.hp.description
        atkLabel.text = card.atk.description
        indexLabel.text = card.index.description
        let text = card.skills.map{ $0.description }.reduce("", { $0 + $1 + "\n"})
        descriptionTextView.text = "レアリティ " + card.rarity.rawValue + "\n" + text
    }
}

