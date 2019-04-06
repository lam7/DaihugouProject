//
//  CardCollectionView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/26.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
//
//class CardCollectionView: UINibView{
//    @IBOutlet weak var collectionView: UICollectionView!{
//        didSet{
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            collectionView.register(UINib(nibName: "CardsCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
//        }
//    }
//    @IBOutlet weak var filterButton: UIButton?
//    @IBOutlet weak var searchBar: UISearchBar?{
//        didSet{
//            searchBar?.delegate = self
//        }
//    }
//    //-TODO: ひもづけ
//    @IBOutlet weak var filterView: CardSortFilterView?
//    //-TODO: ひもづけ
//    @IBOutlet weak var characterDetailView: ClosableCharacterDetailView?
//
//
//    func update(_ indexs: [Int], _ rarities: [CardRarity]){
//        cardsFilter.filter = (indexs, rarities)
//        collectionView.reloadData()
//    }
//
//    func update(_ sort: (Card, Card) -> Bool) {
//        cardsFilter.cards.sort(by: {
//            sort($0.card, $1.card)
//        })
//        collectionView.reloadData()
//    }
//
//
//
//    @IBAction func filterTouchUp(_ sender: UIButton) {
//        filterView?.isHidden = false
//    }
//
//}
//
//
//extension CardCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return cardsFilter.cards.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if !cardsFilter.cards.inRange(indexPath.row){
//            return
//        }
//        let card =  cardsFilter.cards[indexPath.row].card
//        characterDetailView?.isHidden = false
//        characterDetailView?.set(card: card)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CardsCell
//        cell.card = cardsFilter.cards[indexPath.row]
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = collectionView.frame.height
//        let width = height * 3 / 4
//        return CGSize(width: width, height: height)
//    }
//
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//}
//
//extension CardCollectionView: UISearchBarDelegate{
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        guard let text = searchBar.text else{
//            return
//        }
//
//        cardsFilter.searchText = text
//        collectionView.reloadData()
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let text = searchBar.text else{
//            return
//        }
//        cardsFilter.searchText = text
//        collectionView.reloadData()
//    }
//
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        cardsFilter.searchText = ""
//        collectionView.reloadData()
//    }
//}
