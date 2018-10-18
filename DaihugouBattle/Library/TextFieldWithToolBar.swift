//
//  TextFieldWithToolBar.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/27.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
class TextFieldWithTextAndButton: UITextField{
    private var toolBarTextField: UITextField!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        addToolBar()
    }
    
    private func addToolBar(){
        let toolBar: UIToolbar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let textFieldRect = CGRect(x: 0, y: 0, width: SSX * 0.6, height: 28)
        let textField: UITextField = UITextField(frame: textFieldRect)
        textField.isUserInteractionEnabled = false
        self.toolBarTextField = textField
        let leftButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let rightButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let textButton: UIBarButtonItem = UIBarButtonItem(customView: textField)
        
        let doneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.done, target: self, action: #selector(TextFieldWithTextAndButton.donePressed))
        toolBar.setItems([leftButton, textButton, doneButton, rightButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.sizeToFit()
        inputAccessoryView = toolBar
    }
    
    @objc func donePressed(){
        endEditing(true)
    }
    
    override func insertText(_ text: String) {
        super.insertText(text)
        toolBarTextField.text = text
    }

}
