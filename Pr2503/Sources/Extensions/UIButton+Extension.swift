//
//  UIButton+Extension.swift
//  Pr2503
//
//  Created by Elena Noack on 13.07.22.
//

import UIKit

func addStyle(_ buttons: [UIButton]) {
    for button in buttons {
        button.configuration = .tinted()
        button.configuration?.cornerStyle = .large
    }
}

