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
        
        textView.inputAccessoryView = fontPickerView.toolbar
        textView.inputView = fontPickerView
    }
}

