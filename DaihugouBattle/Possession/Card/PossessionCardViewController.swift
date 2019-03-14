//
//  PossessionCardViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/03.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import Hero
import Chameleon
import RxCocoa
import RxSwift
import PhotosUI

extension UIViewController{
    var OKAlertAction: UIAlertAction{
        return UIAlertAction(title: "OK", style: .default, handler: nil)
    }
    
    var BackAlertAction: UIAlertAction{
        return UIAlertAction(title: "戻る", style: .default, handler: {[weak self]_ in self?.dismiss(animated: true, completion: nil)})
    }
    
    func alert(_ error: Error, preferredStyle: UIAlertController.Style = .alert, actions: UIAlertAction...){
        //メッセージ設定
        let error = error as NSError
        let controller = UIAlertController.init(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: preferredStyle)
        
        //ボタンアクションを設定
        actions.forEach{ controller.addAction($0) }
        if controller.actions.isEmpty{
            controller.addAction(OKAlertAction)
        }
        present(controller, animated: true, completion: nil)
    }
}

class PossessionCollectionDataSource: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching{
    typealias Element = [Card]
    var cards: [Card] = []
    var cardCount: CardCount = [:]
    
    /// カード画像を展開しておく。
    ///　サブスレッドであらかじめ画像をロードしておくことでかくつきを減らす
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[Card]>) {
        Binder(self) { dataSource, element in
            dataSource.cards = element
            collectionView.reloadData()
        }.on(observedEvent)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardSheetsStandartCell
        let card = cards[indexPath.row]
        cell.card = card
        if let count = cardCount[card]{
            cell.count = count
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let cards = indexPaths.map{ $0.row }.map({ self.cards[$0] }).map({ $0.imageNamed })
        RealmImageCache.shared.loadImagesBackground(cards, completion: {})
    }
}


class SortFilterViewModel{
//    private var cardsVar: Variable<[Card]> = Variable([Card](repeating: cardNoData, count: 32))
    private var cardsVar: Variable<[Card]> = Variable([])
    var cards: Observable<[Card]>{
        return cardsVar.asObservable()
    }
    
    var originalCards: [Card] = []{
        didSet{
            let cards = CardsSort.sort(originalCards, by: currentSort, isAsc: true)
            cardsVar.value = cards
        }
    }
    private var currentSort: CardsSort.SortBy = CardsSort.SortBy.id
    
    let disposeBag = DisposeBag()
    
    init(filterIndexs: Observable<Set<Int>>, filterRarities: Observable<Set<CardRarity>>, filterText: Observable<String?>, sortBy: Observable<CardsSort.SortBy>, sortIsAsc: Observable<Bool>){
        let filter = Observable.combineLatest(filterIndexs, filterRarities, filterText).debounce(0.01, scheduler: MainScheduler.instance)
        filter.subscribe{
            [weak self] event in
            guard let `self` = self,
                let element = event.element else {
                    return
            }
            let text = element.2 ?? ""
            let cards = CardsFilter.filter(self.originalCards, indexs: element.0.map({$0}), rarities: element.1.map({$0}), text: text)
            self.cardsVar.value = cards
            }.disposed(by: disposeBag)

        let sort = Observable.combineLatest(sortBy, sortIsAsc).debounce(0.01, scheduler: MainScheduler.instance)
        sort.subscribe{[weak self] event in
            guard let `self` = self,
                let element = event.element else {
                    return
            }
            
            let cards = CardsSort.sort(self.cardsVar.value, by: element.0, isAsc: element.1)
            self.cardsVar.value = cards
            self.currentSort = element.0
            }.disposed(by: disposeBag)
    }
}

class PossessionCardViewController: UIViewController{
    @IBOutlet weak var tapableView: TapableView!{
        didSet{
            tapableView.tapped = { [weak self] in
                self?.hiddenViews()
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortFilterView: CardSortFilterView!{
        didSet{
            sortFilterView.closeButton.rx.tap.subscribe{ [weak self] event in
                self?.hiddenViews()
            }.disposed(by: disposeBag)
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var characterDetailView: PossessionCardDetailView!{
        didSet{
            characterDetailView.tappedClose = {[weak self] in
                self?.hiddenViews()
            }
        }
    }
    @IBOutlet weak var backgroundImageView: UIImageView!
    var dataSource: PossessionCollectionDataSource!
    var viewModel: SortFilterViewModel!
    let disposeBag: DisposeBag = DisposeBag()
    
    
    private var incrementalText: Observable<String?> {
        return searchBar.rx.text.asObservable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = DataRealm.get(imageNamed: "black_mamba.png")
        
        collectionView.register(UINib(nibName: "CardSheetsStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        
        dataSource = PossessionCollectionDataSource()
        
        self.dataSource.cardCount = UserInfo.shared.cardsValue
        
        viewModel = SortFilterViewModel(filterIndexs: sortFilterView.indexs.asObservable(), filterRarities: sortFilterView.rarities.asObservable(), filterText: incrementalText, sortBy: sortFilterView.sortBy.asObservable(), sortIsAsc: sortFilterView.sortIsAsc.asObservable())
        viewModel.cards.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func hiddenViews(){
        self.tapableView.isHidden = true
        self.sortFilterView.isHidden = true
        self.characterDetailView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        LoadingView.show()
        let cards = UserInfo.shared.cardsValue.map({ $0.key })
        let nameds = "cardBack.png" + cards.map{ $0.imageNamed }
        RealmImageCache.shared.loadImagesBackground(nameds){
            self.viewModel.originalCards = cards
            LoadingView.hide()
        }
        
    }
    
    @IBAction func touchUpSortFilter(_ sender: UIButton){
        sortFilterView.isHidden = false
        tapableView.isHidden = false
    }
}

extension PossessionCardViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

extension PossessionCardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.height / 3
        let width = height * 3 / 4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = dataSource.cards[indexPath.row]
        characterDetailView.card = card
        characterDetailView.isHidden = false
        tapableView.isHidden = false
    }
}
