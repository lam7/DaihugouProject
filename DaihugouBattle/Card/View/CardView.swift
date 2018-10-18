//
//  CardBattleView.swift
//  DaihugouBattle
//
//  Created by main on 2018/08/22.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit


class CardView: UIView{
    var card: Card?{
        didSet{
            front.set(from: card)
        }
    }
    weak var bothSidesView: BothSidesView!
    weak var front: (DisplayableCard & UIView)!
    weak var back: UIView!
    override var frame: CGRect{
        didSet{
            if bothSidesView == nil{ return }
            bothSidesView.frame = bounds
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bothSidesView = BothSidesView(frame: bounds)
        let front = CardStandartFrontView(frame: bounds)
        let back = CardStandartBackView(frame: bounds)
        bothSidesView.frontView.addSubview(front)
        bothSidesView.backView.addSubview(back)
        addSubview(bothSidesView)
        self.bothSidesView = bothSidesView
        self.front = front
        self.back = back
    }
    
    init(frame: CGRect, front: DisplayableCard & UIView, back: UIView){
        super.init(frame: frame)
        let bothSidesView = BothSidesView(frame: bounds)
        bothSidesView.frontView.addSubview(front)
        bothSidesView.backView.addSubview(back)
        addSubview(bothSidesView)
        self.bothSidesView = bothSidesView
        self.front = front
        self.back = back
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else{
            return nil
        }
        
        //自身のViewかサブビューなら
        if view == self || subviews.reduce(false, { $0 || $1 == view }){
            return self
        }
        
        return nil
    }
    
}
