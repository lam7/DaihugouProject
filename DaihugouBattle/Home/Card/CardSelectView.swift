
//
//  CardSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit


@IBDesignable class CardSelectView: UINibView, SelectableView, DeckSelectDelegate {
    @IBOutlet weak var deckButton: UIButton!
    @IBOutlet weak var possessionButton: UIButton!
    weak var deckSelectView: FormingDeckSelectView?
    weak var displayView: UIView?{
        didSet{
            oldValue?.removeSafelyFromSuperview()
        }
    }
    @IBAction func touchUp(_ sender: UIButton) {
        let viewController = self.parentViewController()
        ManageAudio.shared.play("click.mp3")
        switch sender.tag{
        case 1:
            LoadingView.show()
            let deckSelectView = FormingDeckSelectView(frame: bounds)
            addSubview(deckSelectView)
            self.deckSelectView = deckSelectView
            displayView = deckSelectView
            deckSelectView.delegate = self
            updateDecks({ LoadingView.hide() })
        case 2:
            viewController?.performSegue(withIdentifier: "possessionCard", sender: viewController)
        default:
            break
        }
    }
    
    private func updateDecks(_ completion: (()->())? = nil){
        UserInfo.shared.getAllDeck{ [weak self] decks, error in
            if let error = error{
                guard let controller = self?.parentViewController() else{
                    completion?()
                    return
                }
                controller.alert(error, actions: controller.OKAlertAction)
            }
            self?.deckSelectView?.decks = decks
            completion?()
        }
    }
    
    func selected(_ deck: Deck?) {
        guard let deck = deck as? DeckRelated else{
            parentViewController()?.performSegue(withIdentifier: "deckForming", sender: nil)
            return
        }
        let w = bounds.width * 0.8
        let h = bounds.height * 0.9
        let f = CGRect(center: bounds, width: w, height: h)
        let v = SelectedDeckInCreateDeckView(frame: f)
        addSubview(v)
        v.deck = deck
        v.updateDecks = {
            self.updateDecks()
            v.removeFromSuperview()
        }
    }
}
