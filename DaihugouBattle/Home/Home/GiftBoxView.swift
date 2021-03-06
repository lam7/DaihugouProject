//
//  GiftBoxView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/08.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GiftBoxTableDataSource: NSObject, RxTableViewDataSourceType, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GiftBoxCell
        let giftedItem = giftedItems[indexPath.row]
        cell.set(giftItemInfo: giftedItem)
        cell.gainButton.rx.tap.subscribe{ _ in
            self.gainGiftedItemRelay.accept(giftedItem)
        }.disposed(by: disposeBag)
        return cell
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[GiftedItem]>) {
        Binder(self) { dataSource, element in
            dataSource.giftedItems = element
            tableView.reloadData()
        }.on(observedEvent)
    }

    var gainGiftedItemRelay: PublishRelay<GiftedItem> = PublishRelay()
    private let disposeBag = DisposeBag()
    typealias Element = [GiftedItem]
    var giftedItems: Element = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giftedItems.count
    }
}

class GiftBoxViewModel{
    private var _giftedItemsVar: BehaviorRelay<[GiftedItem]> = BehaviorRelay(value: [])
    private var _receivedGiftedItemsVar:BehaviorRelay<[GiftedItem]> = BehaviorRelay(value: [])
    private var giftedItemsVar: BehaviorRelay<[GiftedItem]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    var giftedItems: Observable<[GiftedItem]>{
        return giftedItemsVar.asObservable()
    }
    init(segmentedControl: Observable<Int>, receiveGiftedItem: Observable<GiftedItem>, collectiveGiftedItems: Observable<Void>, collectiveGiftedItemsEnable: Binder<Bool>, activityIndicatorHidden: Binder<Bool>, alert: PublishRelay<Error>){
        
        let activityVar: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        activityVar.asObservable().bind(to: activityIndicatorHidden).disposed(by: disposeBag)
        func getAllGiftedItemInfos(){
            activityVar.accept(true)
            UserInfo.shared.getAllGiftedItemInfos{ result in
                switch result{
                case .success(let (giftedItems, receivedGiftedItems)):
                    self._giftedItemsVar.accept(giftedItems)
                    self._receivedGiftedItemsVar.accept(receivedGiftedItems)
                    activityVar.accept(false)
                case .failure(let error):
                    alert.accept(error)
                }
            }
        }
        
        getAllGiftedItemInfos()
        
        receiveGiftedItem.subscribe{ event in
            guard let element = event.element else{
                return
            }
            activityVar.accept(true)
            UserInfo.shared.receive(items: [element]){
                error in
                if let error = error{
                    alert.accept(error)
                }
                activityVar.accept(false)
                getAllGiftedItemInfos()
            }
        }.disposed(by: disposeBag)
        
        collectiveGiftedItems.subscribe{ _ in
            activityVar.accept(true)
            UserInfo.shared.receive(items: self._giftedItemsVar.value){ error in
                if let error = error{
                    alert.accept(error)
                }
                activityVar.accept(false)
                getAllGiftedItemInfos()
            }
        }.disposed(by: disposeBag)
        
        segmentedControl.subscribe{ event in
            guard let element = event.element else{
                return
            }
            let isReceived = element == 1
            if isReceived{
                collectiveGiftedItemsEnable.onNext(false)
                self._receivedGiftedItemsVar.asDriver().drive(self.giftedItemsVar).disposed(by: self.disposeBag)
            }else{
                collectiveGiftedItemsEnable.onNext(true)
                self._giftedItemsVar.asDriver().drive(self.giftedItemsVar).disposed(by: self.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
}

class GiftBoxView: UINibView, UITableViewDelegate{
    @IBOutlet weak var giftTableView: UITableView!{
        didSet{
            giftTableView.register(GiftBoxCell.self, forCellReuseIdentifier: "giftBoxCell")
            giftTableView.delegate = self
            giftTableView.dataSource = dataSource
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{
        didSet{
            activityIndicator.transform.scaledBy(x: 10, y: 10)
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectiveButton: UIButton!
    var dataSource: GiftBoxTableDataSource!
    var viewModel: GiftBoxViewModel!
    private let disposeBag = DisposeBag()
    @IBAction func touchUpClose(_ sender: UIButton){
        self.removeFromSuperview()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        giftTableView.register(GiftBoxCell.self, forCellReuseIdentifier: "cell")
        activityIndicator.transform.scaledBy(x: 10, y: 10)
        
        dataSource = GiftBoxTableDataSource()
        let alertRelay = PublishRelay<Error>()
        alertRelay.subscribe{ event in
            guard let error = event.element,
                let vc = self.parentViewController() else{
                return
            }
            vc.alert(error, actions: vc.OKAlertAction)
        }.disposed(by: disposeBag)
        viewModel = GiftBoxViewModel(segmentedControl: segmentedControl.rx.selectedSegmentIndex.asObservable(), receiveGiftedItem: dataSource.gainGiftedItemRelay.asObservable(), collectiveGiftedItems: collectiveButton.rx.tap.asObservable(), collectiveGiftedItemsEnable: collectiveButton.rx.isEnabled, activityIndicatorHidden: activityIndicator.rx.isAnimating, alert: alertRelay)
        viewModel.giftedItems.bind(to: giftTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func removeFromSuperview() {
        UIView.animateCloseWindow(self){
            super.removeFromSuperview()
        }
    }
}
