//
//  SpotCardsCollectionView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/17.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit



class SpotCardsCollectionView: UINibView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var enemyCollectionView: UICollectionView!
    @IBOutlet weak var ownerCollectionView: UICollectionView!
    private var ownerCards: [Card] = []
    private var enemyCards: [Card] = []
    
    var displayChStatus: ((_: Card?) -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        enemyCollectionView.register(UINib(nibName: "CollectionImageViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        ownerCollectionView.register(UINib(nibName: "CollectionImageViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
    }
    func set(spot: Spot){
        ownerCards = spot.ownerCards
        enemyCards = spot.enemyCards
        
        ownerCollectionView.reloadData()
        enemyCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ownerCollectionView{
            return ownerCards.count
        }else{
            return enemyCards.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionImageViewCell
        
        let card = collectionView == ownerCollectionView ? ownerCards[indexPath.row] : enemyCards[indexPath.row]
        
        if let battle = card as? CardBattle{
            (cell.viewWithTag(1) as! UIImageView).image = battle.image
        }else{
            (cell.viewWithTag(1) as! UIImageView).image = card.image
        }
        
        cell.backgroundColor = UIColor(averageColorFrom: card.image)
        //        let imageView = UIImageView(frame: cell.bounds)
        //        imageView.image = card.image
        //        cell.addSubview(imageView)
        //        cell.imageView.image = card.image
        //        cell.backgroundColor = UIColor(averageColorFrom: card.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = height * 3 / 4
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == ownerCollectionView{
            displayChStatus?(ownerCards[safe: indexPath.row])
        }else if collectionView == enemyCollectionView{
            displayChStatus?(enemyCards[safe: indexPath.row])
        }else{
            displayChStatus?(nil)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func touchUp(_ sender: UIButton){
        isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayChStatus?(nil)
    }
}
