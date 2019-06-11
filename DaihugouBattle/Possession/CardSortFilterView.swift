//
//  CardFilterView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/03.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

/////カード情報で検索しフィルターするためのインクリメントサーチバー
//weak var searchBar: UISearchBar!{
//    didSet{
//        searchBar.delegate = self
//    }
//}

@IBDesignable class CardSortFilterView: UINibView{
    typealias CardSortBy = ((Card, Card) -> Bool)
    ///インデックスでフィルターするボタン
    @IBOutlet var indexButtons: [UIButton]!
    ///インデックスではフィルターしないためのボタン
    @IBOutlet weak var indexAllButton: UIButton!
    ///レアリティでフィルターするボタン
    @IBOutlet var rarityButtons: [UIButton]!
    ///レアリティではフィルターしないためのボタン
    ///TODO: ひもづけ
//    @IBOutlet weak var rarityAllButton: UIButton!
    
    ///昇順でソートするためのボタン
    ///TODO: ひもづけ
    @IBOutlet weak var sortOrderAscButton: UIButton!
    ///降順でソートするためのボタン
    @IBOutlet weak var sortOrderDesButton: UIButton!
    ///idでソートするボタン
    ///TODO: ひもづけ
    @IBOutlet weak var sortByIdButton: UIButton!
    ///hpでソートするボタン
    @IBOutlet weak var sortByHpButton: UIButton!
    ///atkでソートするボタン
    @IBOutlet weak var sortByAtkButton: UIButton!
    ///rarityでソートするボタン
    @IBOutlet weak var sortByRarityButton: UIButton!
    ///indexでソートするボタン
    @IBOutlet weak var sortByIndexButton: UIButton!
    ///バツボタン
    @IBOutlet weak var closeButton: UIButton!
    ///ソートボタンとソート方法のディクショナリ
    private var sortByButtons: [UIButton : CardsSort.SortBy]!{
        return [
            sortByIdButton     : .id,
            sortByAtkButton    : .atk,
            sortByHpButton     : .hp,
            sortByIndexButton  : .index,
            sortByRarityButton : .rarity
        ]
    }

    var indexs: Variable<Set<Int>> = Variable([])
    var rarities: Variable<Set<CardRarity>> = Variable([])
    var sortBy: Variable<CardsSort.SortBy>! = Variable(.id)
    var sortIsAsc: Variable<Bool>! = Variable(true)

    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        //個別のボタンがタッチされたならVariableの値を変更する
        //個別のボタンのisSelectedはVariableに要素が含まれているかどうかできまる
        //"すべて"ボタンがタッチされたならVariableに空を突っ込む
        indexButtons.forEach{ button in
            button.rx.tap.subscribe{[weak self] _ in
                guard let `self` = self else { return }
                let index = button.tag
                if !self.indexs.value.contains(index){
                    self.indexs.value.insert(index)
                }else{
                    self.indexs.value.remove(index)
                }
            }.disposed(by: disposeBag)
        }
        
        indexs.asObservable().subscribe{[weak self] event in
            guard let `self` = self,
                let element = event.element else {return}
            if element.isEmpty{
                self.indexAllButton.isSelected = true
            }else{
                self.indexAllButton.isSelected = false
            }
            for button in self.indexButtons{
                let isContain = element.contains(button.tag)
                button.isSelected = isContain
            }
        }.disposed(by: disposeBag)
        
        indexButtons.forEach{button in
            indexs.asObservable().reduce(false, accumulator: {$0 || $1.contains(button.tag)}).subscribe{
                guard let element = $0.element else {return}
                button.isSelected = element
            }.disposed(by: disposeBag)
        }
        
        indexAllButton.rx.tap.subscribe{[weak self] _ in
            guard let `self` = self,
                self.indexs.value != [] else { return }
            self.indexs.value = []
        }.disposed(by: disposeBag)
        
        
        
        rarityButtons.forEach{ button in
            button.rx.tap.subscribe{[weak self] _ in
                guard let `self` = self else { return }
                let rarity = CardRarity.allCases[button.tag]
                if !self.rarities.value.contains(rarity){
                    self.rarities.value.insert(rarity)
                }else{
                    self.rarities.value.remove(rarity)
                }
                
            }.disposed(by: disposeBag)
        }

        rarities.asObservable().subscribe{[weak self] event in
            guard let `self` = self,
                let element = event.element else {return}
            for button in self.rarityButtons{
                let rarity = CardRarity.allCases[button.tag]
                let isContain = element.contains(rarity)
                button.isSelected = isContain
            }
        }.disposed(by: disposeBag)
        
        ///現在選択されているボタン以外がタップされたなら、isSelectedを選択されたボタンのみtrueにする
        sortByButtons.forEach{ button in
            button.key.rx.tap.subscribe{[weak self] _ in
                guard let `self` = self,
                    let sortByButton = self.sortByButtons[button.key],
                    self.sortBy.value != sortByButton else{
                        return
                }
                self.sortBy.value = sortByButton
            }.disposed(by: disposeBag)
        }
        
        sortBy.asObservable().subscribe{[weak self] event in
            guard let `self` = self,
                let element = event.element,
                let button = self.sortByButtons.filter({ $0.value == element }).first?.key else { return }
            self.sortByButtons.forEach({ $0.key.isSelected = false })
            button.isSelected = true
        }.disposed(by: disposeBag)
        
        sortOrderAscButton.rx.tap.subscribe{[weak self] _ in
            guard let `self` = self,
                !self.sortOrderAscButton.isSelected else{ return }
            self.sortIsAsc.value = true
        }.disposed(by: disposeBag)
        
        sortOrderDesButton.rx.tap.subscribe{[weak self] _ in
            guard let `self` = self,
                !self.sortOrderDesButton.isSelected else{ return }
            self.sortIsAsc.value = false
        }.disposed(by: disposeBag)
        
        sortIsAsc.asObservable().subscribe{[weak self] event in
            guard let `self` = self,
                let element = event.element else{ return }
            self.sortOrderAscButton.isSelected = element
            self.sortOrderDesButton.isSelected = !element
        }.disposed(by: disposeBag)
    }
    
    private func getCurrentSelectedSortBy()-> UIButton{
        return sortByButtons.filter({ $0.key.isSelected }).first!.key
    }
//
//    @IBAction func indexTouchUp(_ sender: UIButton) {
//
//        //全ボタンなら
//        if sender.tag == 99{
//            //全てのボタンをキャンセルし、全ボタンをオンにする
//            self.indexButtons.forEach{ $0.isSelected = false }
//            sender.isSelected = true
//        }else{//個別ボタンなら
//            sender.isSelected = !sender.isSelected
//            //全てがオフになっていたら全ボタンをオンに、違うならオフにする
//            if indexButtons.filter({ $0.isSelected }).isEmpty{
//                indexAllButton.isSelected = true
//            }else{
//                indexAllButton.isSelected = false
//            }
//        }
//        filter()
//    }
//
//    @IBAction func rarityTouchUp(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        filter()
//    }
//
//
//    @IBAction func sortTouchUp(_ sender: UIButton){
//        //現在のソートと同じボタンがタッチされているなら何もしない
//        guard let selected = sortByButtons.filter({ $0.isSelected }).first,
//            selected != sender else{
//            return
//        }
//        selected.isSelected = false
//        sender.isSelected = true
//        sort()
//    }
//
//    @IBAction func sortOrderTouchUp(_ sender: UIButton){
//        //現在のソートオーダーと同じボタンがタッチされているなら何もしない
//        guard let selected = sortOrderButtons.filter({ $0.isSelected }).first,
//            selected != sender else{
//            return
//        }
//
//        selected.isSelected = false
//        sender.isSelected = true
//
//    }
//
//    ///現在のソートボタンからisSelectedがtrueなもののカードソート方法を返す
//    private func getSortBy()-> CardSortBy?{
//        let isAsc = sortOrderButtons.filter({ $0.isSelected }).first!.tag == 1
//        let selected = sortByButtons.filter({ $0.isSelected }).first!
//        switch selected.tag{
//        case 1:
//            if isAsc{
//                return { $0.id < $1.id }
//            }else{
//                return { $0.id > $1.id }
//            }
//        case 2:
//            if isAsc{
//                return {
//                    let all = CardRarity.allCases
//                    let h1 = all.firstIndex(of: $0.rarity)!
//                    let h2 = all.firstIndex(of: $1.rarity)!
//                    return h1 > h2
//                }
//            }else{
//                return {
//                    let all = CardRarity.allCases
//                    let h1 = all.firstIndex(of: $0.rarity)!
//                    let h2 = all.firstIndex(of: $1.rarity)!
//                    return h1 < h2
//                }
//            }
//        case 3:
//            if isAsc{
//                return { $0.index < $1.index }
//            }else{
//                return { $0.index > $1.index }
//            }
//        case 4:
//            if isAsc{
//                return { $0.atk < $1.atk }
//            }else{
//                return { $0.atk > $1.atk }
//            }
//
//        case 5:
//            if isAsc{
//                return { $0.hp < $1.hp }
//            }else{
//                return { $0.hp > $1.hp }
//            }
//        default: return nil
//        }
//    }
//
//    private func sort(){
//        guard let by = getSortBy() else{
//            print("Not Exist getSortBy")
//            return
//        }
//    }
//
//    private func filter(){
//        var indexs: [Int] = []
//        if indexAllButton.isSelected{
//            indexs = (1 ... indexButtons.count).map({ $0 })
//        }else{
//            indexs = indexButtons.filter({ $0.tag != 99 && $0.isSelected }).map({ $0.tag })
//        }
//        let rarityFlag = rarityButtons.filter({ $0.isSelected }).map({ $0.tag })
//        var rarities: [CardRarity] = []
//        for r in rarityFlag{
//            switch r{
//            case 1: rarities.append(.UR)
//            case 2: rarities.append(.SR)
//            case 3: rarities.append(.R)
//            case 4: rarities.append(.N)
//            default: fatalError("Button tag is \(r)")
//            }
//        }
//        if rarities.isEmpty{
//            rarities = [.UR, .SR, .R, .N]
//        }
//        delegate?.update(indexs, rarities)
//    }
//
//    func update(){
//    }
//
//    @IBAction func closeTouchUp(_ sender: UIButton) {
//        self.isHidden = true
//    }
}
