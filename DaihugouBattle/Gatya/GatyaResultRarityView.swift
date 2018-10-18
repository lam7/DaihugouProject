////
////  GatyaResultRarityView.swift
////  DaihugouBattle
////
////  Created by Main on 2018/06/05.
////  Copyright © 2018年 Main. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class GatyaResultRarityView: UIView{
//    @IBOutlet weak var backView: UIView!
//    @IBOutlet weak var label: UILabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//    var underLineColors: [UIColor] = [.white]
//    var cards: [CardCount] = []
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    private func setUp(){
//        backViewSetUp()
////        collectionView.register(UINib(nibName: T##String, bundle: nil), forCellWithReuseIdentifier: "cell")
//    }
//    
//    private func backViewSetUp(){
//        let gradientLayer = CAGradientLayer()
//        let height: CGFloat = 2.0
//        gradientLayer.frame = CGRect(x: 0, y: backView.frame.height - height / 2, width: backView.frame.width, height: height)
//        gradientLayer.colors = underLineColors
//        backView.layer.addSublayer(gradientLayer)
//    }
//}
//
//extension GatyaResultRarityView: UICollectionViewDelegate, UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return cards.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        return cell
//    }
//}
