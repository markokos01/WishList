//
//  WLTextField.swift
//  WishList
//
//  Created by Marko Kos on 10.01.2023..
//

import UIKit

class WLTextField: UITextField {

    var textPadding = UIEdgeInsets(
        top: 8,
        left: 16,
        bottom: 8,
        right: -16
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

}
