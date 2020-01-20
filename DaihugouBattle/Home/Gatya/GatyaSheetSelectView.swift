//
//  GatyaSheetSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

@IBDesignable class GatyaSheetSelectView: UINibView{
    var max: Int!
    var buyType: GatyaBuyType!
    var gatyaType: GatyaType!
    
    var numOfSheet: BehaviorRelay<Int> = BehaviorRelay(value: 1){
        willSet{
            if newValue.value < 1{
                newValue.accept(1)
            }else if newValue.value > max{
                newValue.accept(max)
            }
        }
    }
    @IBOutlet weak var sheetCountLabel: UILabel!
    @IBOutlet weak var possessionLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var maxButton: UIButton!
    let disposeBag = DisposeBag()
    
    func setUp(max: Int, buyType: GatyaBuyType, gatyaType: GatyaType){
        self.max = max
        self.buyType = buyType
        self.gatyaType = gatyaType
        
        switch buyType{
        case .gold:
            possessionLabel.text = UserInfo.shared.goldValue.description
        case .crystal:
            possessionLabel.text = UserInfo.shared.crystalValue.description
        case .ticket:
            possessionLabel.text = UserInfo.shared.ticketValue.description
        }
        
        numOfSheet.asObservable()
            .map({ $0.description })
            .bind(to: sheetCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        numOfSheet.asObservable()
            .map({ $0 != 1 })
            .bind(to: minusButton.rx.isEnabled )
            .disposed(by: disposeBag)
        
        numOfSheet.asObservable()
            .map({ $0 != max })
            .bind(to: plusButton.rx.isEnabled )
            .disposed(by: disposeBag)
    }
    
    @IBAction func regulationSheet(_ sender: UIButton){
        let v = numOfSheet.value
        switch sender.tag{
        case 1:
            numOfSheet.accept(v - 1)
        case 2:
            numOfSheet.accept(v + 1)
        case 3:
            numOfSheet.accept(max)
        default:
            break
        }

    }
    
    @IBAction func back(_ sender : UIButton){
        self.removeFromSuperview()
    }
    
    @IBAction func buy(_ sender: UIButton){
        let gatya = GatyaServerAndLocal(buyType: buyType, rollTimes: numOfSheet.value, gatyaType: gatyaType)
        self.parentViewController()?.performSegue(withIdentifier: "gatya", sender: gatya)
    }
    
}
