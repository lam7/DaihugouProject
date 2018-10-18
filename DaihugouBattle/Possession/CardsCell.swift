//
//  CardCell.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/25.
//  Copyright © 2018年 Main. All rights reserved.
//

import UIKit

class CardsCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var viewBehindLabel: UIView!
    
    var card: Card?{
        didSet{
            guard let card = card else{
                imageView.image = nil
                return
            }
            imageView.image = card.image
        }
    }
    
    var count: Int?{
        didSet{
            guard let count = count else{
                label.text = ""
                return
            }
            label.text = "× " + count.description
        }
    }
}
