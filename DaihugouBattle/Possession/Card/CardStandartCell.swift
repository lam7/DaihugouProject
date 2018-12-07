//
//  CardStandartCell.swift
//  DaihugouBattle
//
//  Created by main on 2018/06/18.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class CardStandartCell: UICollectionViewCell{
    var card: Card!{
        didSet{
            guard oldValue != card else{
                return
            }
            standartView.set(from: card)
        }
    }
    
    @IBOutlet weak var standartView: CardStandartFrontView!
}


