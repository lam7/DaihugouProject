//
//  DeckSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/17.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import Chameleon

protocol DeckSelectDelegate: class{
    func selected(_ deck: Deck?)
}

class DeckSelectView: UINibView, DeckSelectPageViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    lazy var numPages: Int = pageControl.numberOfPages
    
    private (set) var pages = [UIView?]()
    var decks: [Deck]!{
        didSet{
            self.loadCurrentPages(page: 0)
        }
    }
    
    weak var delegate: DeckSelectDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp(){
        pages = [UIView?](repeating: nil, count: numPages)
        backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        scrollView.backgroundColor = backgroundColor
        setupInitialPages()
    }
    
    private func setupInitialPages(){
        adjustScrollView()
    }
    
    private func adjustScrollView() {
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(numPages), height: scrollView.frame.height)
    }
    
    private func loadPage(_ page: Int) {
        guard 0 <= page && page < numPages else { return }
        print("loadPage \(page)")
        if pages[page] == nil{
            let width = scrollView.bounds.width * 0.95
            let height = scrollView.bounds.height * 0.95
            var x = scrollView.frame.midX - width / 2
            x += scrollView.bounds.width * page.cf
            let y = scrollView.frame.midY - height / 2
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let selectPageView = DeckSelectPageView(frame: frame)
            scrollView.addSubview(selectPageView)
            selectPageView.backgroundColor = self.backgroundColor
            selectPageView.delegate = self
            let count = selectPageView.selectButtons.count
            selectPageView.selectButtons.enumerated().forEach({ i, button in
                let index = count * page + i
                button.tag = index
                if let deck = decks[safe: index]{
                    settingDeckButton(button, deck: deck)
                }else if decks.count == index{
                    settingDeckLastButton(button)
                }else{
                    settingNothingButton(button)
                }
            })
            pages[page] = selectPageView
        }
    }
    
    func settingDeckButton(_ button: UIButton, deck: Deck){
        button.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        button.tintColor = .flatWhite()
        button.setTitle(deck.name, for: UIControl.State.normal)
        button.titleLabel?.text = deck.name
    }
    
    func settingDeckLastButton(_ button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.6)
        button.isEnabled = false
    }
    
    func settingNothingButton(_ button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.6)
        button.isEnabled = false
    }
    
    func loadCurrentPages(page: Int) {
        guard 0 <= page && page < numPages else { return }
        
//        // Remove all of the images and start over.
//        removeAnyPageView()
//        pages = [UIView?](repeating: nil, count: numPages)
        
        // Load the appropriate new pages for scrolling.
        if page == 0{
            loadPage(numPages - 1)
        }else{
            loadPage(page - 1)
        }
        loadPage(page)
        if page == numPages - 1{
            loadPage(0)
        }else{
            loadPage(page + 1)
        }
        
    }
    
    func removeAnyPageView() {
        for page in pages where page != nil {
            page?.removeFromSuperview()
        }
    }


    func gotoPage(page: Int, animated: Bool) {
        loadCurrentPages(page: page)
        
        // Update the scroll view scroll position to the appropriate page.
        var bounds = scrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(page)
        bounds.origin.y = 0
        scrollView.scrollRectToVisible(bounds, animated: animated)
    }
    
    @IBAction func gotoPage(_ sender: UIPageControl) {
        // User tapped the page control at the bottom, so move to the newer page, with animation.
        gotoPage(page: sender.currentPage, animated: true)
    }
    
    func backPage(){
        if pageControl.currentPage == 0{
            let last = pageControl.numberOfPages - 1
            pageControl.currentPage = last
        }else{
            pageControl.currentPage -= 1
        }
        gotoPage(page: pageControl.currentPage, animated: true)
    }
    
    func nextPage() {
        let last = pageControl.numberOfPages - 1
        if pageControl.currentPage == last{
            pageControl.currentPage = 0
        }else{
            pageControl.currentPage += 1
        }
        gotoPage(page: pageControl.currentPage, animated: true)
    }
    
    @IBAction func backPage(_ sender: UIButton){
        backPage()
    }
    
    @IBAction func nextPage(_ sender: UIButton){
        nextPage()
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer){
        nextPage()
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer){
        backPage()
    }
    func selectButtonAction(_ sender: UIButton) {
        if let deck = decks[safe: sender.tag]{
            
            delegate?.selected(deck)
        }else if sender.tag == decks.count{
            delegate?.selected(nil)
            
        }
    }
//
//    func selectButtonAction(_ sender: UIButton) {
//        if let deck = decks[safe: sender.tag]{
//            delegate?.selected(deck)
//        }else if sender.tag == decks.count{
//            delegate?.selected(nil)
//        }
//    }
}


class FormingDeckSelectView: DeckSelectView{
    override var nibName: String{
        return DeckSelectView.className
    }
    
    override func settingDeckLastButton(_ button: UIButton) {
        button.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 0.6957940925)
        button.tintColor = .flatWhite()
        button.setTitle("デッキ作成", for: UIControl.State.normal)
        button.titleLabel?.text = "デッキ作成"
    }

}
