//
//  SelectedDeckInBattleView.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/19.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class SelectedDeckInBattleView: UINibView{
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var sortieButton: UIButton!
    @IBOutlet weak var deckNameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var deck: Deck!{
        didSet{
            deckNameLabel.text = (deck as? DeckRelated)?.name
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event) ?? self
    }
    
    @IBAction func touchUpConfirmation(_ sender: UIButton){
        let v = DeckConfirmationView(frame: UIScreen.main.bounds)
        v.deckCards = deck.cards
        self.parentViewController()?.view.addSubview(v)
    }
    
    @IBAction func touchUpSortie(_ sender: UIButton){
        self.parentViewController()?.performSegue(withIdentifier: "battle", sender: deck)
    }
    
    @IBAction func touchUpClose(_ sender: UIButton){
        self.removeFromSuperview()
    }
}
