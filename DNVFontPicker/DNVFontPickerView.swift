//
//  DNVFontPickerView.swift
//  DNVFontPicker
//
//  Created by Alexey Demin on 2017-02-28.
//  Copyright © 2017 Alexey Demin. All rights reserved.
//

import UIKit


class DNVFontPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    let fontPickerView = UIPickerView()
    
    
    var toolbar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.bounds.size.height = 44
        return toolbar
    }
    
    
    enum PickerComponent {
        case fontName, fontSize, fontColor
        
        init?(_ component: Int, forPicker picker: DNVFontPickerView) {
            
            switch component {
            case 0:
                self = .fontName
            case 1 where picker.fontSizes != nil:
                self = .fontSize
            case 1 where picker.fontColors != nil, 2 where picker.fontColors != nil:
                self = .fontColor
            default:
                return nil
            }
        }
        
        static func count(forPicker picker: DNVFontPickerView) -> Int {
            
            return 1 + (picker.fontSizes != nil ? 1 : 0) + (picker.fontColors != nil ? 1 : 0)
        }
    }
    
    
    public var fontNames = UIFont.familyNames {
        didSet {
            fontPickerView.reloadComponent(0)
        }
    }
    
    public var fontSizes = [7, 8, 9, 10, 11, 12, 14, 16, 18, 24, 36, 48, 64] as [CGFloat]? {
        didSet {
            fontPickerView.reloadAllComponents()
        }
    }
    
    public var fontColors = DNVFontPickerView.colors(count: 16) {
        didSet {
            fontPickerView.reloadAllComponents()
        }
    }
    
    
    static func colors(count: Int) -> [UIColor]? {
        
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
    
    
    var attributes = [String : Any]() {
        didSet {
            onUpdate?(attributes)
        }
    }
    
    
    public var onUpdate: ((_ attributes: [String : Any]) -> ())?
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        bounds.size.height = 200
        
        fontPickerView.frame = bounds
        fontPickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fontPickerView.dataSource = self
        fontPickerView.delegate = self
        addSubview(fontPickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return PickerComponent.count(forPicker: self)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch PickerComponent(component, forPicker: self)! {
        case .fontName:
            return fontNames.count
            
        case .fontSize:
            return fontSizes!.count
            
        case .fontColor:
            return fontColors!.count
        }
    }
    
    
    // MARK - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if let view = view {
            return view
        }
        
        switch PickerComponent(component, forPicker: self)! {
        case .fontName:
            let fontNameLabel = UILabel()
            fontNameLabel.textAlignment = .center
            fontNameLabel.font = UIFont(name: fontNames[row], size: 16)
            fontNameLabel.text = fontNames[row]
            return fontNameLabel
            
        case .fontSize:
            let fontSizeLabel = UILabel()
            fontSizeLabel.textAlignment = .center
            fontSizeLabel.text = String(describing: fontSizes![row])
            return fontSizeLabel
            
        case .fontColor:
            let fontColorView = UIView()
            fontColorView.backgroundColor = fontColors![row]
            return fontColorView
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        switch PickerComponent(component, forPicker: self)! {
        case .fontName:
            return pickerView.bounds.width / 2
            
        case .fontSize:
            return pickerView.bounds.width / 4
            
        case .fontColor:
            return pickerView.bounds.width / 6
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch PickerComponent(component, forPicker: self)! {
        case .fontName:
            let font = UIFont(name: fontNames[row], size: (attributes[NSFontAttributeName] as? UIFont)?.pointSize ?? fontSizes?[row] ?? UIFont.systemFontSize)!
            attributes[NSFontAttributeName] = font
            
        case .fontSize:
            let font = (attributes[NSFontAttributeName] as? UIFont)?.withSize(fontSizes![row]) ?? UIFont(name: fontNames[row], size: fontSizes![row])!
            attributes[NSFontAttributeName] = font
            
        case .fontColor:
            attributes[NSForegroundColorAttributeName] = fontColors![row]
        }
    }
}
