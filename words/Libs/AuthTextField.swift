//
//  AuthTextField.swift
//  words
//
//  Created by Neo Ighodaro on 19/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class AuthTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderStyle = .roundedRect
        layer.borderColor = UIColor.lightGray.cgColor
    }
}
