//
//  ViewController.swift
//  DNVFontPicker
//
//  Created by Alexey Demin on 2017-02-28.
//  Copyright © 2017 Alexey Demin. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    
    let fontPickerView = DNVFontPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.allowsEditingTextAttributes = true
        
        fontPickerView.textView = textView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let animationCurve = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue else {
            return
        }
        
        let bottomInset = self.view.bounds.height - self.view.convert(keyboardFrame.origin, from: nil).y
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(animationCurve) << 16), animations: {
            
            self.textView.contentInset.bottom = bottomInset
            self.textView.scrollIndicatorInsets.bottom = bottomInset
        })
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        fontPickerView.update(attributes: textView.typingAttributes)
    }
}

