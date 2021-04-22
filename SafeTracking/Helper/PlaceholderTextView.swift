//
//  PlaceholderTextView.swift
//
//  Created by CHEEBOW on 2015/07/24.
//  Copyright (c) 2015年 CHEEBOW. All rights reserved.
//

import UIKit

public class PlaceholderTextView: UITextView {
    let placeholderLeftMargin: CGFloat = 10.0
    let placeholderTopMargin: CGFloat = 8.0
    
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.alpha = 1.0
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 4
        self.layer.cornerRadius = 7
        self.layer.borderColor = UIColor(hex6: 0xefefef).cgColor
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.tintColor = UIColor(red: 214/255, green: 215/255, blue: 216/255, alpha: 1)
        
        return label
    }()

    @IBInspectable
    public var placeholderColor: UIColor = UIColor(hex6: 0xBBBBC2) {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    @IBInspectable
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            placeholderSizeToFit()
        }
    }
    
    override public var text: String! {
        didSet {
            textChanged(nil)
        }
    }

    override public var font: UIFont? {
        didSet {
            placeholderLabel.font = font
            placeholderSizeToFit()
        }
    }
    
    fileprivate func placeholderSizeToFit() {
        placeholderLabel.frame = CGRect(x: placeholderLeftMargin, y: placeholderTopMargin, width: frame.width - placeholderLeftMargin * 2, height: 0.0)
        placeholderLabel.sizeToFit()
    }

    fileprivate func setup() {
        //textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        font = UIFont(name: "HelveticaNeue", size: 14)
        placeholderLabel.font = self.font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.text = placeholder
        placeholderSizeToFit()
        addSubview(placeholderLabel)

        self.sendSubviewToBack(placeholderLabel)

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(PlaceholderTextView.textChanged(_:)), name: UITextView.textDidChangeNotification, object: nil)
        
        textChanged(nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }

    @objc func textChanged(_ notification:Notification?) {
        placeholderLabel.alpha = self.text.isEmpty ? 1.0 : 0.0
    }
    
}
