//
//  DNVFontPickerView.swift
//  DNVFontPicker
//
//  Created by Alexey Demin on 2017-02-28.
//  Copyright © 2017 Alexey Demin. All rights reserved.
//

import UIKit


typealias PickerViewComponent = DNVFontPickerView.PickerViewComponent
typealias ToolbarComponent = DNVFontPickerView.ToolbarComponent

protocol PickerComponent { }


extension UIFont {
    
    open class var systemFontFamilyName: String {
        
        return UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName
    }
    
    
    open func withFamilyName(_ fontFamilyName: String) -> UIFont {
        
        if let fontDescriptor = fontDescriptor.withFamily(fontFamilyName).matchingFontDescriptors(withMandatoryKeys: [UIFontDescriptorFamilyAttribute]).first {
            return UIFont(descriptor: fontDescriptor, size: pointSize)
        }
        else {
            return self
        }
    }
    
    
    func withPickerComponent(_ component: PickerComponent) -> UIFont {
        
        switch component {
        case let PickerViewComponent.fontFamily(family):
            return withFamilyName(family)
            
        case let PickerViewComponent.fontSize(size):
            return withSize(size)
            
        default:
            return self
        }
    }
}


class DNVFontPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    public let pickerView = UIPickerView()
    
    
    var toolbar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.bounds.size.height = 44
        
        let fontBBI = UIBarButtonItem(title: "Font", style: .plain, target: self, action: #selector(switchKeyboard(sender:)))
        let spaceBBI = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBBI = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard(sender:)))
        
        toolbar.items = [fontBBI, spaceBBI, doneBBI]
        
        return toolbar
    }
    
    
    public weak var textView: UITextView? {
        didSet {
            guard let textView = textView else {
                return
            }
            
            textView.inputAccessoryView = toolbar
            
            update(attributes: textView.typingAttributes)
            
            onUpdate = { component in
                
                let attributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
                let selectedRange = textView.selectedRange
                
                switch component {
                case PickerViewComponent.fontFamily, PickerViewComponent.fontSize, ToolbarComponent.isBold, ToolbarComponent.isItalic:
                    attributedString.enumerateAttribute(NSFontAttributeName, in: selectedRange) { attribute, range, _ in
                        
                        let font = (attribute as! UIFont).withPickerComponent(component)
                        attributedString.addAttribute(NSFontAttributeName, value: font, range: range)
                    }
                    let font = (textView.typingAttributes[NSFontAttributeName] as! UIFont).withPickerComponent(component)
                    textView.typingAttributes[NSFontAttributeName] = font
                    
                case let PickerViewComponent.fontColor(color):
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: selectedRange)
                    textView.typingAttributes[NSForegroundColorAttributeName] = color
                    
                case let ToolbarComponent.isUnderlined(underlined):
                    break
                    
                case let ToolbarComponent.isStrikethrough(strikethrough):
                    break
                    
                case let ToolbarComponent.isHighlighted(highlighted):
                    break
                    
                default:
                    break
                }
                
                textView.attributedText = attributedString.copy() as! NSAttributedString
                textView.selectedRange = selectedRange
            }
        }
    }
    
    
    enum ToolbarComponent: PickerComponent {
        
        case isBold(Bool), isItalic(Bool), isUnderlined(Bool), isStrikethrough(Bool), isHighlighted(Bool)
    }
    
    
    enum PickerViewComponent: PickerComponent {
        
        case fontFamily(String), fontSize(CGFloat), fontColor(UIColor)
        
        
        init?(_ component: Int, forPicker picker: DNVFontPickerView, selectedRow row: Int? = nil) {
            
            switch component {
            case 0:
                self = .fontFamily(row != nil ? picker.fontFamilies[row!] : UIFont.systemFontFamilyName)
                
            case 1 where picker.fontSizes != nil:
                self = .fontSize(row != nil ? picker.fontSizes![row!] : UIFont.systemFontSize)
                
            case 1 where picker.fontColors != nil, 2 where picker.fontColors != nil:
                self = .fontColor(row != nil ? picker.fontColors![row!] : .black)
                
            default:
                return nil
            }
        }
        
        
        static func count(forPicker picker: DNVFontPickerView) -> Int {
            
            return 1 + (picker.fontSizes != nil ? 1 : 0) + (picker.fontColors != nil ? 1 : 0)
        }
    }
    
    
    public var fontFamilies: [String] = [UIFont.systemFontFamilyName] + UIFont.familyNames {
        didSet {
            if !fontFamilies.contains(UIFont.systemFontFamilyName) {
                fontFamilies.insert(UIFont.systemFontFamilyName, at: 0)
            }
            pickerView.reloadComponent(0)
        }
    }
    
    public var fontSizes: [CGFloat]? = [7, 8, 9, 10, 11, 12, 14, 16, 18, 24, 36, 48, 64] {
        didSet {
            fontSizes?.sort()
            pickerView.reloadAllComponents()
        }
    }
    
    public var fontColors: [UIColor]? = DNVFontPickerView.colors(count: 16) {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    
    public static func colors(count: Int) -> [UIColor]? {
        
        if count < 1 {
            return nil
        }
        
        var colors: [UIColor] = [.black]
        
        if count > 1 {
            colors.append(.gray)
        }
        
        if count > 2 {
            for i in 0..<count - 2 {
                let color = UIColor(hue: CGFloat(i) / CGFloat(count - 2), saturation: 1, brightness: 1, alpha: 1)
                colors.append(color)
            }
        }
        return colors
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        pickerView.frame = bounds
        pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pickerView.dataSource = self
        pickerView.delegate = self
        addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func update(attributes: [String: Any]) {
        
        let font = attributes[NSFontAttributeName] as? UIFont ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        pickerView.selectRow(fontFamilies.index(of: font.familyName) ?? 0, inComponent: 0, animated: false)
        
        if let fontSizes = fontSizes {
            if fontSizes.index(of: font.pointSize) == nil {
                self.fontSizes!.append(font.pointSize)
            }
            pickerView.selectRow(self.fontSizes!.index(of: font.pointSize)!, inComponent: 1, animated: false)
        }
        
        if let fontColors = fontColors {
            let color = attributes[NSForegroundColorAttributeName] as? UIColor ?? .black
            if fontColors.index(of: color) == nil {
                self.fontColors!.append(color)
            }
            pickerView.selectRow(self.fontColors!.index(of: color)!, inComponent: (fontSizes == nil ? 1 : 2), animated: false)
        }
    }
    
    
    public var onUpdate: ((_ component: PickerComponent) -> ())?
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return PickerViewComponent.count(forPicker: self)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch PickerViewComponent(component, forPicker: self)! {
        case .fontFamily:
            return fontFamilies.count
            
        case .fontSize:
            return fontSizes!.count
            
        case .fontColor:
            return fontColors!.count
        }
    }
    
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let view = view {
            return view
        }
        
        switch PickerViewComponent(component, forPicker: self)! {
        case .fontFamily:
            let fontNameLabel = UILabel()
            fontNameLabel.textAlignment = .center
            fontNameLabel.font = UIFont(name: fontFamilies[row], size: 16)
            fontNameLabel.text = fontFamilies[row]
            return fontNameLabel
            
        case .fontSize:
            let fontSizeLabel = UILabel()
            fontSizeLabel.textAlignment = .center
            let size = fontSizes![row]
            fontSizeLabel.text = (size.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.f", size) : String(describing: size))
            return fontSizeLabel
            
        case .fontColor:
            let fontColorView = UIView()
            fontColorView.backgroundColor = fontColors![row]
            return fontColorView
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        switch PickerViewComponent(component, forPicker: self)! {
        case .fontFamily:
            return pickerView.bounds.width / 2
            
        case .fontSize:
            return pickerView.bounds.width / 4
            
        case .fontColor:
            return pickerView.bounds.width / 6
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        onUpdate?(PickerViewComponent(component, forPicker: self, selectedRow: row)!)
    }
    
    
    
    // MARK: - UIBarButtonItem Actions
    
    func switchKeyboard(sender: UIBarButtonItem) {
        
        if textView?.inputView == nil {
            textView?.inputView = self
            sender.title = "Keyboard"
        } else {
            textView?.inputView = nil
            sender.title = "Font"
        }
        textView?.reloadInputViews()
    }
    
    
    func hideKeyboard(sender: UIBarButtonItem) {
        
        textView?.inputView = nil
        textView?.resignFirstResponder()
    }
}
