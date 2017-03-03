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
        
        updatePicker()
        
        fontPickerView.onUpdate = { attributes in
            let range = self.textView.selectedRange
            let attributedString = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.addAttributes(attributes, range: range)
//            attributedString.setAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
            self.textView.attributedText = attributedString.copy() as! NSAttributedString
            self.textView.selectedRange = range
            
//            self.textView.typingAttributes = attributes
            for (key, value) in attributes {
                self.textView.typingAttributes[key] = value
            }
        }
        
        let toolbar = UIToolbar()
        toolbar.bounds.size.height = 44
        let fontBBI = UIBarButtonItem(title: "Font", style: .plain, target: self, action: #selector(switchKeyboard(sender:)))
        let spaceBBI = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBBI = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard(sender:)))
        toolbar.items = [fontBBI, spaceBBI, doneBBI]
        textView.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
//        let topInset = UIApplication.shared.statusBarFrame.height
//        textView.contentInset.top = topInset
//        textView.scrollIndicatorInsets.top = topInset
    }
    
    
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    
    func switchKeyboard(sender: UIBarButtonItem) {
        
        if textView.inputView == nil {
            textView.inputView = fontPickerView
            sender.title = "Keyboard"
        } else {
            textView.inputView = nil
            sender.title = "Font"
        }
        textView.reloadInputViews()
    }
    
    
    func hideKeyboard(sender: UIBarButtonItem) {
        
        textView.inputView = nil
        textView.resignFirstResponder()
    }
    
    
    func updatePicker() {
        
//        if textView.attributedText.length == 0 {
//            return
//        }
        
//        let index = min(max(0, textView.selectedRange.location + textView.selectedRange.length - 1), textView.attributedText.length - 1)
//        fontPickerView.update(attributes: textView.attributedText.attributes(at: index, effectiveRange: nil))
        fontPickerView.update(attributes: textView.typingAttributes)
    }
    
    
    func keyboardWillChangeFrame(notification: Notification) {
        
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
        
        updatePicker()
    }
}

