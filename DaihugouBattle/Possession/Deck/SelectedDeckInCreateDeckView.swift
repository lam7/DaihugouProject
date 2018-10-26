//
//  SelectedDeckInCreateDeckView
//  DaihugouBattle
//
//  Created by Main on 2018/05/20.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class SelectedDeckInCreateDeckView: UINibView, BlockableOutsideTouchView{
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
    
    weak var behindView: UIView?
    
    var updateDecks: (() -> ())?
    
    var deck: DeckRelated!{
        didSet{
            nameLabel.text = deck.name
            cardSleeveImageView.image = RealmImageCache.shared.image("cardBack.png")
            deckIndexBarGraph.indexCounts(from: deck)
        }
    }
    
    override func didMoveToSuperview() {
        behindView = setUpBehindView()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil{
            behindView?.removeSafelyFromSuperview()
        }
    }
    
    @IBAction func touchUpRename(_ sender: UIButton){
        
    }
    
    @IBAction func touchUpChangingSleeve(_ sender: UIButton){
        
    }
    @IBAction func touchUpChangingSkin(_ sender: UIButton){
        
    }
    
    @IBAction func touchUpClose(_ sender: UIButton){
        self.removeSafelyFromSuperview()
    }
    
    @IBAction func touchUpDeckForming(_ sender: UIButton){
        self.removeSafelyFromSuperview()
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
        guard let objectId = deck.objectId else{
            return
        }
        
        UserInfo.shared.remove(deck: objectId, completion: { [weak self] error in
            if let error = error{
                guard let controller = self?.parentViewController() else{
                    return
                }
                controller.alert(error, actions: controller.OKAlertAction)
            }
            self?.removeSafelyFromSuperview()
            self?.updateDecks?()
        })
    }
    
    
}
