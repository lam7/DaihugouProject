//
//  DeckCollectionDataSource.swift
//  DaihugouBattle
//
//  Created by main on 2019/09/26.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class DeckCollectionDataSource: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching{
    typealias Element = [Card]
    var cards: [Card] = []
    

    private func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[Card]>) {
        Binder(self) { dataSource, element in
            if dataSource.cards.count == 0 &&  element.count == 0{
                return
            }
            if dataSource.cards.count < element.count{
                var t = element
                for card in dataSource.cards{
                    t.remove(at: t.firstIndex(of: card)!)
                }
                dataSource.cards = element
                
                var indexPaths: [IndexPath] = []
                for c in t{
                    guard let i = dataSource.cards.firstIndex(of: c) else{ continue }
                    let indexPath = IndexPath(row: i, section: 0)
                    print(indexPath)
                    indexPaths.append(indexPath)
                }
                collectionView.insertItems(at: indexPaths)
                if let indexPath = indexPaths.first{
                    collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                }
            }else{
                var t = dataSource.cards
                for card in element{
                    t.remove(at: t.firstIndex(of: card)!)
                }
                var indexPaths: [IndexPath] = []
                for c in t{
                    guard let i = dataSource.cards.firstIndex(of: c) else{ continue }
                    let indexPath = IndexPath(row: i, section: 0)
                    print(indexPath)
                    indexPaths.append(indexPath)
                }
                dataSource.cards = element
                collectionView.deleteItems(at: indexPaths)
            }
        }.on(observedEvent)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardStandartCell
        let card = cards[indexPath.row]
        cell.card = card
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let cards = indexPaths.map{ $0.row }.map({ self.cards[$0] }).map({ $0.imageNamed })
        RealmImageCache.shared.loadImagesBackground(cards, completion: {})
    }
}
