//
//  CollectionCardViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/03.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Chameleon

class CollectionCardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    @IBOutlet var collectionView: UICollectionView!
    private var selectedCard: Card?
    @IBOutlet weak var characterDetailView: CollectionCardDetailView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterView: PossessionCardFilterView!
    private var userInfo: UserInfo!
    private var cards: [(card: Card, count: Int)] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userInfo != nil{
            return
        }
        userInfo = UserInfo(){ error in
            self.cards = self.userInfo.cards
            self.collectionView.reloadData()
        }
        filterView.apply = applyFilter(indexs:rarities:)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addTDPView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !cards.inRange(indexPath.row){
            return
        }
        let card =  cards[indexPath.row].card
        characterDetailView.isHidden = false
        characterDetailView.set(card: card)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        guard let image = ImageRealm.get(imageNamed: cards[indexPath.row].0.imageNamed) else{
            return cell
        }
        let imageView = cell.viewWithTag(1) as! UIImageView
        let countLabel = cell.viewWithTag(2) as! UILabel
        imageView.image = image
        countLabel.text = cards[indexPath.row].count.description
        cell.backgroundColor = UIColor(averageColorFrom: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.view.frame.height / 3
        let width = height * 3 / 4
        return CGSize(width: width, height: height)
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    @IBAction func filterTouchUp(_ sender: UIButton) {
        filterView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else{
            return
        }
        search(text)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else{
            return
        }
        search(text)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cards = userInfo.cards
        collectionView.reloadData()
        
    }
    
    private func search(_ text: String){
        var result: [(card: Card, count: Int)] = []
        for (card, count) in userInfo.cards{
            if count == 0{ continue }
            if card.name.contains(text){
                result.append((card, count))
            }
        }
        cards = result
        collectionView.reloadData()
    }
    
    private func applyFilter(indexs: [Int], rarities: [Rarity]){
        var r = userInfo.cards
        
        if !indexs.isEmpty{
            r = r.filter({
                for index in indexs{
                    if $0.card.index == index{
                        return true
                    }
                }
                return false
            })
        }
        
        if !rarities.isEmpty{
            r = r.filter({
                for rarity in rarities{
                    if $0.card.rarity == rarity{
                        return true
                    }
                }
                return false
            })
        }
        
        cards = r
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "swipeable"{
            let controller = segue.destination as! ZLSwipeableViewController
            controller.cards = self.cards
        }
    }
    

}
