//
//  GatyaView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/13.
//  Copyright © 2017年 Main. All rights reserved.
//

import UIKit
import RxSwift

///一回でガチャを引くことが出来る最大回数
let NumTimesCanRollGatyaAtOneTime = 10

@IBDesignable class GatyaSelectView: UINibView, UIPickerViewDelegate, UIPickerViewDataSource, SelectableView {
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var possessionGoldLabel: UILabel!
    @IBOutlet weak var possessionCrystalLabel: UILabel!
    @IBOutlet weak var possessionTicketLabel: UILabel!
    @IBOutlet weak var consumeGold: UILabel!
    @IBOutlet weak var consumeTicket: UILabel!
    @IBOutlet weak var consumeCrystal: UILabel!
    @IBOutlet weak var goldButton: UIButton!
    @IBOutlet weak var crystalButton: UIButton!
    @IBOutlet weak var ticketButton: UIButton!
    
    private weak var selectView: GatyaSheetSelectView!
    private var gatyaTypes: [GatyaType]!
    let disposeBag = DisposeBag()
    var goldButtonDisposable: Disposable?
    var crystalButtonDisposable: Disposable?
    var ticketButtonDisposable: Disposable?
    
    var selectedGatyaId: Int{
        return typePicker.selectedRow(inComponent: 0)
    }
    weak var displayView: UIView?{
        didSet{
            oldValue?.removeSafelyFromSuperview()
        }
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }
    
    private func setUp(){
        gatyaTypes = []
        setUpPicker()
        setUpLabel()
    }
    
    private func setUpPicker(){
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    private func setUpButton(){
        guard let gatyaType: GatyaType = gatyaTypes[safe: selectedGatyaId] else{
            return
        }
        
        goldButtonDisposable?.dispose()
        crystalButtonDisposable?.dispose()
        ticketButtonDisposable?.dispose()
        
        goldButtonDisposable = UserInfo.shared.gold
            .map({ $0 >= gatyaType.consume.gold })
            .bind(to: goldButton.rx.isEnabled)
        
        crystalButtonDisposable = UserInfo.shared.crystal
            .map({ $0 >= gatyaType.consume.crystal })
            .bind(to: crystalButton.rx.isEnabled)
        
        ticketButtonDisposable = UserInfo.shared.ticket
            .map({ $0 >= gatyaType.consume.ticket })
            .bind(to: ticketButton.rx.isEnabled)
    }
    
    private func setUpLabel(){
//        UserInfo.shared.addObserver("userInfo", self)
        UserInfo.shared.ticket
            .map({String($0)})
            .bind(to: possessionTicketLabel.rx.text)
            .disposed(by: disposeBag)
        
        UserInfo.shared.gold
            .map({String($0)})
            .bind(to: possessionGoldLabel.rx.text)
            .disposed(by: disposeBag)
        
        UserInfo.shared.crystal
            .map({String($0)})
            .bind(to: possessionCrystalLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @IBAction func buy(_ sender: UIButton) {
        guard let gatyaType: GatyaType = gatyaTypes[safe: selectedGatyaId] else{
            return
        }
        
        if selectView == nil{
            let space: CGFloat = 20
            let frame: CGRect = CGRect(x: space, y: 0, width: SSX - space * 2, height: SSY)
            let selectView = GatyaSheetSelectView(frame: frame)
            selectView.alpha = 0.8
            selectView.tag = 99
            self.parentViewController()?.view.addSubview(selectView)
            self.selectView = selectView
        }
        displayView = selectView
        var buyType: GatyaBuyType = .gold
        var max: Int = 0
        switch sender.tag {
        case 1:
            max = min(NumTimesCanRollGatyaAtOneTime, UserInfo.shared.goldValue / gatyaType.consume.gold)
            buyType = GatyaBuyType.gold
        case 2:
            max = min(NumTimesCanRollGatyaAtOneTime, UserInfo.shared.crystalValue / gatyaType.consume.crystal)
            buyType = GatyaBuyType.crystal
            
        case 3:
            max = min(NumTimesCanRollGatyaAtOneTime, UserInfo.shared.ticketValue / gatyaType.consume.ticket)
            buyType = GatyaBuyType.ticket
        default:
            print("GatyaSelectView-buy error sender.tag = \(sender.tag)")
            return
        }
        selectView.setUp(max: max, buyType: buyType, gatyaType: gatyaType)
      
        selectView.isHidden = max <= 0
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gatyaTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: pickerView.frame)
        label.text = gatyaTypes[row].name
        label.textColor = .white
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if gatyaTypes.outOfRange(row){
            return
        }
        let type = gatyaTypes[row]
        consumeGold.text    = "１パック\(type.consume.gold)ゴールド"
        consumeTicket.text  = "１パック\(type.consume.ticket)チケット"
        consumeCrystal.text = "１パック\(type.consume.crystal)クリスタル"
        imageView.image = DataRealm.get(imageNamed: type.imagePath)
        setUpButton()
    }
    
    func initGatyaType(){
        LoadingView.show()
        GatyaServerAndLocal.getTypes{
            [weak self]types, error in
            guard let `self` = self else {
                return
            }
            if let error = error{
                let errorAlart = UIAlertController(title: "サーバー通信エラー", message: nil, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "ホームに戻る", style: .default, handler: {
                    action in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let next = storyboard.instantiateViewController(withIdentifier: "home")
                    self.parentViewController()?.present(next, animated: true, completion: nil)
                })
                errorAlart.addAction(alertAction)
                errorAlart.message = error.localizedDescription
                print(error)
                self.parentViewController()?.present(errorAlart, animated: true, completion: {})
                return
            }
            self.gatyaTypes = types
            self.typePicker.reloadAllComponents()
            LoadingView.hide()
        }
    }
}
