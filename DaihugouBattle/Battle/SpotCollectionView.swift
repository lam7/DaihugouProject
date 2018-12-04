//
//  SpotCollectionView.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/30.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class SpotCollectionView: UINibView{
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            collectionView.register(UINib(nibName: "CollectionHeaderView", bundle: nil).self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    private var originalCards: [(cards: [Card], isOwnerTurn: Bool)] = []
    
    func reloadData(_ originalCards: [(cards: [Card], isOwnerTurn: Bool)]){
        self.originalCards = originalCards
        self.collectionView.reloadData()
    }
    
    func insertData(_ originalCard: (cards: [Card], isOwnerTurn: Bool)){
        let section = self.originalCards.count
        self.originalCards.append(originalCard)
        self.collectionView.insertSections(IndexSet(arrayLiteral: section))
    }
    
    func deleteAllData(){
        let count = originalCards.count
        originalCards = []
        let indexSet = IndexSet((0..<count).map{$0})
        self.collectionView.deleteSections(indexSet)
    }

    
    @IBAction func touchUpClose(_ sender: Any) {
        self.isHidden = true
    }
}

extension SpotCollectionView: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return originalCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return originalCards[section].cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardStandartCell
        cell.card = originalCards[indexPath.section].cards[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! CollectionHeaderView
            let isOwnerTurn = originalCards[indexPath.section].isOwnerTurn
            header.headerLabel.text = isOwnerTurn ? "あなた" : "敵"
            return header
        }
        return UICollectionReusableView()
    }
}
