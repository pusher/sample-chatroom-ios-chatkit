//
//  RoundButton.swift
//  words
//
//  Created by Neo Ighodaro on 19/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
