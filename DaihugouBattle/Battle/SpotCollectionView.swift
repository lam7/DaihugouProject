//
//  SpotCollectionView.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/30.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit
import UICollectionViewFlexLayout

//class UICollectionFlowLayout_Background: UICollectionViewFlowLayout{
//    static let elementKindSectionBackground = "UICollectionElementKindSectionBackground"
//    var sectionBackgroundAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
//
//    override func
//}
class SpotCollectionView: UINibView{
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
//            (collectionView.collectionViewLayout as! UICollectionViewFlexLayout).scrollDirection = .horizontal
            collectionView.register(UINib(nibName: "SpotCollectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            collectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionBackground, withReuseIdentifier: "sectionBackground")
        }
    }

    var cardsWithIdentifier: [([Card], Bool)] = []
}

extension SpotCollectionView: UICollectionViewDelegateFlexLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return cardsWithIdentifier[section].0.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cardsWithIdentifier.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardStandartCell
        cell.card = cardsWithIdentifier[indexPath.section].0[indexPath.row]
        cell.countLabel.isHidden = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlexLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.height
        let w = h * 3 / 4
        return CGSize(width: w, height: h)
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionElementKindSectionBackground:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionBackground", for: indexPath)
            view.backgroundColor = cardsWithIdentifier[indexPath.section].1 ? .green : .red
            return view
        default:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SpotCollectionHeader
            view.label.text = cardsWithIdentifier[indexPath.section].1 ? "あなた" : "てき"
            return view
        }
    }

//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        print(kind)
//        switch kind {
//        case UICollectionElementKindSectionBackground: // section background
//            dump(indexPath)
//            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionBackground, withReuseIdentifier: "sectionBackground", for: indexPath)
//            view.backgroundColor = cardsWithIdentifier[indexPath.section].1 ? .green : .red
//            return view
//        default: return UICollectionReusableView()
//        }
//    }
}
