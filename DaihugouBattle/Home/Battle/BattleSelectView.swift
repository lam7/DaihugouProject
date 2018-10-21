//
//  BattleSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//
 
import UIKit

@IBDesignable class BattleSelectView: UINibView, SelectableView, DeckSelectDelegate {
    weak var displayView: UIView?{
        didSet{
            oldValue?.removeSafelyFromSuperview()
        }
    }
    
    @IBAction func touchUp(_ sender: UIButton) {
        ManageAudio.shared.play("click.mp3")
        LoadingView.show()
        let deckSelectView = DeckSelectView(frame: bounds)
        addSubview(deckSelectView)
        displayView = deckSelectView
        deckSelectView.delegate = self
        UserInfo.shared.getAllDeck{ decks, error in
            LoadingView.hide()
            if let error = error{
                guard let controller = self.parentViewController() else{
                    return
                }
                controller.alert(error, actions: controller.OKAlertAction)
            }
            deckSelectView.decks = decks
        }
    }
    
    func selected(_ deck: Deck?) {
        guard let deck = deck,
            let view = self.parentViewController()?.view else{
            return
        }
        
        let w = view.bounds.width * 0.6
        let h  = w * 0.5
        let v = SelectedDeckInBattleView(frame: CGRect(center: view.bounds, width: w, height: h))
        v.deck = deck
        view.addSubview(v)
    }
    
}
