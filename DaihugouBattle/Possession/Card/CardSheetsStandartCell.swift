//
//  CardSheetsStandartCell.swift
//  DaihugouBattle
//
//  Created by main on 2018/12/07.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class CardSheetsStandartCell: UICollectionViewCell{
    var card: Card!{
        didSet{
            guard oldValue != card else{
                return
            }
            standartView.set(from: card)
        }
    }
    
    var count: Int!{
        didSet{
            guard oldValue != count else{
                return
            }
            countLabel.text = "× " + count.description
        }
    }
    
    @IBOutlet weak var standartView: CardStandartFrontView!
    @IBOutlet weak var countLabel: UILabel!{
        didSet{
            countLabel.frame.origin.y = -countLabel.frame.height * 0.8
        }
    }
}


