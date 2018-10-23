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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardStandartCell
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
            cardsVar.value = originalCards
        }
    }
    private var currentSort: CardsSort.SortBy = CardsSort.SortBy.id
    
    let disposeBag = DisposeBag()
    
    init(filterIndexs: Observable<Set<Int>>, filterRarities: Observable<Set<CardRarity>>, filterText: Observable<String>, sortBy: Observable<CardsSort.SortBy>, sortIsAsc: Observable<Bool>){
        let filter = Observable.combineLatest(filterIndexs, filterRarities, filterText).debounce(0.01, scheduler: MainScheduler.instance)
        filter.subscribe{
            [weak self] event in
            guard let `self` = self,
                let element = event.element else {
                    return
            }
            let cards = CardsFilter.filter(self.originalCards, indexs: element.0.map({$0}), rarities: element.1.map({$0}), text: element.2)
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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sortFilterView: CardSortFilterView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var characterDetailView: PossessionCardDetailView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var dataSource: PossessionCollectionDataSource!
    var viewModel: SortFilterViewModel!
    let disposeBag: DisposeBag = DisposeBag()
    
    
    private var incrementalText: Driver<String> {
        return rx
            .methodInvoked(#selector(PossessionCardViewController.searchBar(_:shouldChangeTextIn:replacementText:)))
            .debounce(0.2, scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<String> in .just(self?.searchBar.text ?? "") }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = DataRealm.get(imageNamed: "black_mamba.png")
        
        collectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        
        dataSource = PossessionCollectionDataSource()
        
        self.dataSource.cardCount = UserInfo.shared.cardsValue
        
        viewModel = SortFilterViewModel(filterIndexs: sortFilterView.indexs.asObservable(), filterRarities: sortFilterView.rarities.asObservable(), filterText: incrementalText.asObservable(), sortBy: sortFilterView.sortBy.asObservable(), sortIsAsc: sortFilterView.sortIsAsc.asObservable())
//        viewModel.cards.asDriver(onErrorJustReturn: []).drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.cards.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        sortFilterView.closeButton.rx.tap.subscribe{ [weak self] event in
            self?.sortFilterView.isHidden = true
        }.disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        LoadingView.show()
        let cards = CardsSort.sort(UserInfo.shared.cardsValue.map{ $0.key }, by: .id, isAsc: true)
        let nameds = cards.map{ $0.imageNamed } + "cardBack.png"
        RealmImageCache.shared.loadImagesBackground(nameds){
            self.viewModel.originalCards = cards
            LoadingView.hide()
        }
        
    }
    
    @IBAction func touchUpSortFilter(_ sender: UIButton){
        sortFilterView.isHidden = false
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
    }
}

//class PossessionCardViewController: TDPViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CardFilterDelegate{
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var filterView: CardSortFilterView!
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var characterDetailView: PossessionCardDetailView!
////    private var selectedCard: Card?
////    private var cardsFilter: CardsFilter!
////
////
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        collectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
//
//        searchBar.rx.text.asDriver().
////        collectionView.register(UINib(nibName: "CardsCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        cardsFilter = CardsFilter(cards: [])
//        UserInfo.shared.update{error in
//            if let error = error{
//                print(error)
//            }
//            self.cardsFilter.originalCards = UserInfo.shared.cardsValue
//            self.collectionView.reloadData()
//        }
//        filterView.delegate = self
//        characterDetailView.delegate = touchHidden
//    }
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
//       collectionView.reloadData()
//    }
//
//
//    func touchHidden(_ possessionCardDetailView: PossessionCardDetailView){
//        possessionCardDetailView.isHidden = true
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return cardsFilter.cards.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if !cardsFilter.cards.inRange(indexPath.row){
//            return
//        }
//        let card =  cardsFilter.cards[indexPath.row].card
//        characterDetailView.isHidden = false
//        characterDetailView.set(card: card)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CardStandartCell
//        cell.card = cardsFilter.cards[indexPath.row]
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CardsCell
////        cell.card = cardsFilter.cards[indexPath.row]
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = self.view.frame.height / 3
//        let width = height * 3 / 4
//        return CGSize(width: width, height: height)
//    }
//
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//
//    @IBAction func filterTouchUp(_ sender: UIButton) {
//        filterView.isHidden = false
//    }
//
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
//
//    private func applyFilter(indexs: [Int], rarities: [CardRarity]){
//        cardsFilter.filter = (indexs, rarities)
//        collectionView.reloadData()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
//
//
//}
