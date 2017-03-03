//
//  DNVFontPickerView.swift
//  DNVFontPicker
//
//  Created by Alexey Demin on 2017-02-28.
//  Copyright © 2017 Alexey Demin. All rights reserved.
//

import UIKit


class DNVFontPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    public let pickerView = UIPickerView()
    
    /*
    var toolbar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.bounds.size.height = 44
        return toolbar
    }
    */
    
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
    
    
    public var fontNames = NSArray(array: [UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName]).addingObjects(from: UIFont.familyNames) as! [String] {
        didSet {
            pickerView.reloadComponent(0)
        }
    }
    
    public var fontSizes = [7, 8, 9, 10, 11, 12, 14, 16, 18, 24, 36, 48, 64] as [CGFloat]? {
        didSet {
            fontSizes?.sort()
            pickerView.reloadAllComponents()
        }
    }
    
    public var fontColors = DNVFontPickerView.colors(count: 16) {
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
    
    
    private var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    
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
        
        font = attributes[NSFontAttributeName] as? UIFont ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        pickerView.selectRow(fontNames.index(of: font.familyName) ?? 0, inComponent: 0, animated: false)
        
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
    
    
    public var onUpdate: ((_ attributes: [String: Any]) -> ())?
    
    
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
            font = UIFont(name: fontNames[row], size: font.pointSize)!
            onUpdate?([NSFontAttributeName: font])
            
        case .fontSize:
            font = font.withSize(fontSizes![row])
            onUpdate?([NSFontAttributeName: font])
            
        case .fontColor:
            let color = fontColors![row]
            onUpdate?([NSForegroundColorAttributeName: color])
        }
    }
}
