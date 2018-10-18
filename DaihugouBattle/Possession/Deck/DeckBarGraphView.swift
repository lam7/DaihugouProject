//
//  DeckBarGraph.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/29.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class DeckBarGraphView: UIView{
    var deck: CreateDeck!{
        didSet{
//            barGraphViews.forEach{
//                $0.removeSafelyFromSuperview()
//            }
//            barGraphViews = []
//
//            let space: CGFloat = 5
//            let dWidth: CGFloat = frame.width - space * deck.CountOfSameIndex.count.cf
//            let width: CGFloat =  dWidth / deck.CountOfSameIndex.count.cf
//            let infos: [(key: Int, value: Int)] = deck.CountOfSameIndex.sorted(by: { $0.key < $1.key })
//            for (i, info) in infos.enumerated(){
//                let x = i * width + space * i
//                let frame = CGRect(x: x, y: 0, width: width, height: self.frame.height)
//                let barGraphView = BarGraphView(frame: frame)
//                barGraphView.bottomLabel.text = info.key.description
//                addSubview(barGraphView)
//                barGraphViews.append(barGraphView)
//            }
        }
    }
    var barGraphViews: [BarGraphView] = []
    
    
    func update(_ card: Card, duration: TimeInterval = 0.25){
//        let infos = deck.CountOfSameIndex.sorted(by: { $0.key < $1.key })
//        for (i, info) in infos.enumerated(){
//            if info.key == card.index{
//                let barGraph = barGraphViews[i]
//                let cards = deck.deckCards.filter({ $0.card.index == card.index })
//                let count = cards.reduce(0, { $0 + $1.count })
//                barGraph.topLabel.text = count.description
//                let ratio = count.cf / info.value.cf
//                barGraph.barGraphLayer.update(to: ratio)
//                break
//            }
//        }
    }
    
}
