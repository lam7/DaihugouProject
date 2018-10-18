
//
//  CardSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit


@IBDesignable class CardSelectView: UINibView, SelectableView, DeckSelectDelegate {
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
        case 2:
            viewController?.performSegue(withIdentifier: "possessionCard", sender: viewController)
        default:
            break
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
        v.deck = deck
        addSubview(v)
    }
}
