//
//  SelectedDeckInCreateDeckView
//  DaihugouBattle
//
//  Created by Main on 2018/05/20.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

protocol SelectedDeckInCreateDeckDelegate{
    func deckForming(_ deck: Deck)
    
}
class SelectedDeckInCreateDeckView: UINibView{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameChangingButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var chImageView: UIImageView!
    @IBOutlet weak var chChangingButton: UIButton!
    @IBOutlet weak var cardSleeveImageView: UIImageView!
    @IBOutlet weak var cardSleeveChangingButton: UIButton!
    @IBOutlet weak var deckIndexBarGraph: DeckIndexBarGraph!
    @IBOutlet weak var deckRemovingButton: UIButton!
    @IBOutlet weak var deckFormingButton: UIButton!
    @IBOutlet weak var deckConfirmingButton: UIButton!
    
    var deck: DeckRelated!{
        didSet{
            nameLabel.text = deck.name
            cardSleeveImageView.image = RealmImageCache.shared.image("cardBack.png")
            deckIndexBarGraph.indexCounts(from: deck)
        }
    }
    
    
    @IBAction func touchUpDeckForming(_ sender: UIButton){
        parentViewController()?.performSegue(withIdentifier: "deckForming", sender: deck)
    }
    
    @IBAction func touchUpDeckConfirming(_ sender: UIButton){
        let v = DeckConfirmationView(frame: UIScreen.main.bounds)
        _ = v.closeButton.rx.tap.subscribe{
            [weak self] in
            guard let `self` = self else {
                return
            }
            v.removeFromSuperview()
        }
        v.deckCards = deck.cards
        parentViewController()?.view.addSubview(v)
    }
    
    @IBAction func touchUpDeckRemoving(_ sender: UIButton){
        self.removeFromSuperview()
    }
    

}
