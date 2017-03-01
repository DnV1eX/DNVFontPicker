//
//  ViewController.swift
//  DNVFontPicker
//
//  Created by Alexey Demin on 2017-02-28.
//  Copyright © 2017 Alexey Demin. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    
    let fontPickerView = DNVFontPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontPickerView.onUpdate = { attributes in
            let attributedString = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.setAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
            self.textView.attributedText = attributedString.copy() as! NSAttributedString
        }
        textView.inputAccessoryView = fontPickerView.toolbar
        textView.inputView = fontPickerView
    }
}

