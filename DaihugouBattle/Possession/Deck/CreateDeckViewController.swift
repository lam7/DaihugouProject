//
//  CreateDeckViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/06.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DeckCollectionDataSource: NSObject, RxCollectionViewDataSourceType, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching{
    typealias Element = [Card]
    var cards: [Card] = []
    

    func numberOfSections(in tableView: UITableView) -> Int {
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
                    t.remove(at: t.index(of: card)!)
                }
                dataSource.cards = element
                
                var indexPaths: [IndexPath] = []
                for c in t{
                    guard let i = dataSource.cards.index(of: c) else{ continue }
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
                    t.remove(at: t.index(of: card)!)
                }
                var indexPaths: [IndexPath] = []
                for c in t{
                    guard let i = dataSource.cards.index(of: c) else{ continue }
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
        cell.countLabel.isHidden = true
        cell.card = card
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let cards = indexPaths.map{ $0.row }.map({ self.cards[$0] }).map({ $0.imageNamed })
        RealmImageCache.shared.loadImagesBackground(cards, completion: {})
    }
}

class CreateDeckViewController: UIViewController{
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var touchedCardView: CardStandartFrontView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var statusDetailView: CharacterStatusDetailView!
    @IBOutlet weak var possessionCollectionView: UICollectionView!{
        didSet{
            possessionCollectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            possessionCollectionView.delegate = self
            possessionCollectionView.dataSource = possessionDataSource
            possessionCollectionView.prefetchDataSource = possessionDataSource
        }
    }
    @IBOutlet weak var deckCollectionView: UICollectionView!{
        didSet{
            deckCollectionView.register(UINib(nibName: "CardStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            deckCollectionView.delegate = self
            deckCollectionView.dataSource = deckDataSource
            deckCollectionView.prefetchDataSource = deckDataSource
        }
    }
    @IBOutlet weak var deckBarGraphView: DeckIndexBarGraph!
    
    @IBOutlet weak var possessionSortFilterView: CardSortFilterView!{
        didSet{
            possessionSortFilterView.closeButton.rx.tap.subscribe{ [weak self] event in
                self?.possessionSortFilterView.isHidden = true
                }.disposed(by: disposeBag)
        }
    }
    
    @IBOutlet weak var possessionSearchBar: UISearchBar!
    private var possessionIncrementalText: Driver<String> {
        return rx
            .methodInvoked(#selector(CreateDeckViewController.searchBar(_:shouldChangeTextIn:replacementText:)))
            .debounce(0.2, scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<String> in .just(self?.possessionSearchBar.text ?? "") }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }
    private var possessionDataSource = PossessionCollectionDataSource()
    private var possessionViewModel: SortFilterViewModel!
    private var deckDataSource: DeckCollectionDataSource = DeckCollectionDataSource()
    var createDeck: CreateDeck!{
        didSet{
            createDeck.possessionCards.subscribe{
                [weak self] event in
                guard let `self` = self else {
                    return
                }
                
                self.possessionDataSource.cardCount = event.element!
                if let collection = self.possessionCollectionView,
                    let cells = collection.visibleCells as? [CardStandartCell]{
                    for cell in cells{
                        guard let card = cell.card else{ continue }
                        cell.count = self.possessionDataSource.cardCount[card]
                    }
                }
            }.disposed(by: disposeBag)
            
            createDeck.deckCards.subscribe{
                [weak self] event in
                guard let `self` = self, let deckBarGraphView = self.deckBarGraphView else {
                    return
                }
                
                deckBarGraphView.deckIndexMax = 5
                deckBarGraphView.indexCounts(from: event.element!)
            }.disposed(by: disposeBag)
        }
    }
    private let possessionTag = 1
    private let deckTag = 2
    private var selectedImageView: UIImageView?
    private var isCreating: Bool = false
    private var touchedCard: Card?
    private var touchedIsPossession: Bool = false
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = DataRealm.get(imageNamed: "black_mamba.png")
        
        possessionViewModel = SortFilterViewModel(filterIndexs: possessionSortFilterView.indexs.asObservable(), filterRarities: possessionSortFilterView.rarities.asObservable(), filterText: possessionIncrementalText.asObservable(), sortBy: possessionSortFilterView.sortBy.asObservable(), sortIsAsc: possessionSortFilterView.sortIsAsc.asObservable())
        possessionViewModel.cards.bind(to: possessionCollectionView.rx.items(dataSource: possessionDataSource)).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoadingView.show()
        let cards = CardsSort.sort(UserInfo.shared.cardsValue.map{ $0.key }, by: .id, isAsc: true)
        let nameds = cards.map{ $0.imageNamed } + "cardBack.png"

        RealmImageCache.shared.loadImagesBackground(nameds){
            self.createDeck.set(possessionCards: UserInfo.shared.cardsValue)
            self.possessionViewModel.originalCards = self.createDeck.originalPossessionCards
            self.createDeck.deckCards.bind(to: self.deckCollectionView.rx.items(dataSource: self.deckDataSource)).disposed(by: self.disposeBag)
            LoadingView.hide()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        statusDetailView.isHidden = true
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer){
        switch sender.state{
        case .began:
            var c: Card?
            if let card = getCard(possessionCollectionView, pan: sender){
                c = card
                touchedIsPossession = true
            }else if let card = getCard(deckCollectionView, pan: sender){
                c = card
                touchedIsPossession = false
            }
            
            if let card = c{
                statusDetailView.card = card
                statusDetailView.isHidden = false
                
                if createDeck.possessionCardsValue[card]! <= 0{
                    return
                }
                touchedCard = card
                touchedCardView.set(from: card)
                touchedCardView.center = sender.location(in: self.view)
                touchedCardView.isHidden = false
            }
        case .changed:
            touchedCardView.center = sender.location(in: self.view)
        case .ended, .cancelled, .failed, .possible:
            guard let touchedCard = self.touchedCard else{
                return
            }
            if touchedIsPossession{
                if touchedCardView.center.y <= deckCollectionView.frame.maxY{
                    do{
                        try createDeck.append(touchedCard)
                    }catch{
                        self.alert(error, actions: OKAlertAction)
                    }
                }
            }else{
                if touchedCardView.center.y > deckCollectionView.frame.maxY{
                    do{
                        try createDeck.remove(touchedCard)
                    }catch{
                        self.alert(error, actions: OKAlertAction)
                    }
                }
            }
            self.touchedCard = nil
            touchedCardView.isHidden = true
            
        }
    }
    
    func getCard(_ collectionView: UICollectionView, touch: UITouch)-> Card?{
        let location = touch.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else{
            print("indexPath")
            return nil
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardStandartCell
        return cell.card
    }
    
    func getCard(_ collectionView: UICollectionView, pan: UIPanGestureRecognizer) -> Card?{
        let location = pan.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: location) else{
            return nil
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! CardStandartCell
        return cell.card
    }
    
    
    
    @IBAction func touchUpSortFilter(_ sender: UIButton){
        possessionSortFilterView.isHidden = false
    }
    
    @IBAction func touchUpClose(_ sender: UIButton){
        do{
            try createDeck.canCreate()
            if createDeck.deck != nil{
                let d = createDeck.create()
                UserInfo.shared.append(deck: d, completion: { error in
                    if let error = error{
                        self.alert(error, actions: self.BackAlertAction)
                    }
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }
            let width: CGFloat = view.frame.width * 0.6
            let height: CGFloat = 100
            let frame = CGRect(x: view.frame.midX - width / 2, y: view.frame.midY - height / 2, width: width, height: height)
            let nameView = InputNameView(frame: frame)
            nameView.backgroundColor = .black
            nameView.okButton.backgroundColor = .white
            nameView.okButton.tintColor = .black
            nameView.titleLabel.textColor = .white
            nameView.okButton.rx.tap.subscribe{ _ in
                let deck = self.createDeck.create(nameView.textField.text ?? "")
                UserInfo.shared.append(deck: deck, completion: { error in
                    if let error = error{
                        self.alert(error, actions: self.BackAlertAction)
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }.disposed(by: disposeBag)
            view.addSubview(nameView)
            
        }catch(let error){
            alert(error, actions: OKAlertAction, BackAlertAction)
        }
    }
}

extension CreateDeckViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

extension CreateDeckViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = height * 3 / 4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = collectionView == possessionCollectionView ? possessionDataSource.cards[indexPath.row] : deckDataSource.cards[indexPath.row]
        statusDetailView.card = card
        statusDetailView.isHidden = false
    }
}
