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
import SVProgressHUD

class CreateDeckViewController: UIViewController{
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var touchedCardView: CardStandartFrontView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var statusDetailView: CharacterStatusDetailView!
    @IBOutlet weak var possessionSearchBar: UISearchBar!
    @IBOutlet weak var deckBarGraphView: DeckIndexBarGraph!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var tapableView: TapableView!{
        didSet{
            tapableView.tapped = {[weak self] in
                self?.tapableView.isHidden = true
                self?.possessionSortFilterView.isHidden = true
                self?.nameView?.removeSafelyFromSuperview()
                self?.panGesture.isEnabled = true
            }
        }
    }
    @IBOutlet weak var possessionCollectionView: UICollectionView!{
        didSet{
            possessionCollectionView.register(UINib(nibName: "CardSheetsStandartCell", bundle: nil), forCellWithReuseIdentifier: "cell")
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
    @IBOutlet weak var possessionSortFilterView: CardSortFilterView!{
        didSet{
            possessionSortFilterView.closeButton.rx.tap.subscribe{ [weak self] event in
                self?.possessionSortFilterView.isHidden = true
                self?.tapableView.isHidden = true
                self?.panGesture.isEnabled = true
            }.disposed(by: disposeBag)
        }
    }
    weak var nameView: InputNameView?{
        didSet{
            nameView?.backgroundColor = .black
            nameView?.okButton.backgroundColor = .white
            nameView?.okButton.tintColor = .black
            nameView?.titleLabel.textColor = .white
            nameView?.textField.delegate = self
            nameView?.okButton.rx.tap.subscribe{ [weak self]_ in
                self?.didFinishFormingDeck()
            }.disposed(by: disposeBag)
            tapableView.isHidden = false
        }
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
                    let cells = collection.visibleCells as? [CardSheetsStandartCell]{
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
    private var didFinishForming = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.image = DataRealm.get(imageNamed: "black_mamba.png")
        configureObserver()
        
        let possessionIncrementalText = possessionSearchBar.rx.text.asObservable()
        possessionViewModel = SortFilterViewModel(filterIndexs: possessionSortFilterView.indexs.asObservable(), filterRarities: possessionSortFilterView.rarities.asObservable(), filterText: possessionIncrementalText, sortBy: possessionSortFilterView.sortBy.asObservable(), sortIsAsc: possessionSortFilterView.sortIsAsc.asObservable())
        possessionViewModel.cards.bind(to: possessionCollectionView.rx.items(dataSource: possessionDataSource)).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        if nameView?.textField.isEditing ?? false{
            nameView?.endEditing(true)
        }
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
        
        let cell = collectionView.cellForItem(at: indexPath)
        var card: Card?
        if let cell = cell as? CardStandartCell{
            card = cell.card
        }else{
            card = (cell as! CardSheetsStandartCell).card
        }
        return card
    }
    
    
    
    @IBAction func touchUpSortFilter(_ sender: UIButton){
        possessionSortFilterView.isHidden = false
        tapableView.isHidden = false
        panGesture.isEnabled = false
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
            view.addSubview(nameView)
            self.nameView = nameView
            
        }catch(let error){
            alert(error, actions: OKAlertAction, BackAlertAction)
        }
    }
    
    private func didFinishFormingDeck(){
        if didFinishForming{
            return
        }
        didFinishForming = true
        let deck = self.createDeck.create(nameView?.textField.text ?? "")
        UserInfo.shared.append(deck: deck, completion: { error in
            if let error = error{
                self.alert(error, actions: self.BackAlertAction)
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func configureObserver() {
         let notification = NotificationCenter.default
         notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                  name: UIResponder.keyboardWillShowNotification, object: nil)
         notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボードが表示時に画面をずらす。
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let frame = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let nameView = self.nameView else { return }
        let y = frame.minY - nameView.frame.height - 20
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: y)
            nameView.transform = transform
        }
    }
    
    /// キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.nameView?.transform = CGAffineTransform.identity
        }
    }
}

extension CreateDeckViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
}

extension CreateDeckViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameView?.textField:
            didFinishFormingDeck()
        default:
            break
        }
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
