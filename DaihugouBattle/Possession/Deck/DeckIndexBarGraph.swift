//
//  DeckIndexBarGraph.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/19.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class DeckIndexBarGraph: BarGraphView{
    var deckIndexMax: Int?
    var indexCounts: [Int : Int] = [:]{
        didSet{
            if self.indexCounts.isEmpty { return }
            let indexCounts = self.indexCounts.sorted(by: { $0.key < $1.key })
            let max = deckIndexMax ?? indexCounts.map({$0.value}).max() ?? 1
            self.barRatings = indexCounts.map({ $0.value.cf / max.cf })
            barViews.enumerated().forEach{ i, v in
                v.barLayer.strokeColor = UIColor.green.cgColor
                v.barLayer.borderWidth = 1.0
                v.barLayer.borderColor = UIColor.white.cgColor
                v.topLabel.text = indexCounts[i].value.description
                v.topLabel.textColor = .white
                v.bottomLabel.text = indexCounts[i].key.description
                v.bottomLabel.textColor = .white
            }
        }
    }
    
    func indexCounts(from deck: Deck){
        indexCounts(from: deck.cards)
    }
    
    func indexCounts(from cards: [Card]){
        var indexCounts: [Int : Int] = [:]
        for i in StandartCardIndexRange{
            indexCounts[i] = 0
        }
        cards.map({ $0.index }).forEach({
            if indexCounts[$0] == nil{ indexCounts[$0] = 1}
            else{ indexCounts[$0]! += 1}
        })
        self.indexCounts = indexCounts
    }
}
