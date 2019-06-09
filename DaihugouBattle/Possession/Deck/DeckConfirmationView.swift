//
//  DeckConfirmationView.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/15.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class DeckConfirmationView: UINibView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBAction func touchUpClose(_ sender: UIButton){
        self.removeFromSuperview()
    }
    
    var deckCards: [Card]!{
        didSet{
            collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deckCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardStandartCell
        cell.card = deckCards[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.height * 0.45
        let w = h * 3 / 4
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = deckCards[indexPath.row]
        let characterDetailView = ClosableCharacterDetailView(frame: CharacterDetailViewFrame)
        characterDetailView.card = card
        HUD.show(.closableDark)
        HUD.container.addSubview(characterDetailView)
//        characterDetailView.close = {
//            HUD.dismiss()
//        }
    }
}
