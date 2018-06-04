//
//  PillLabel.swift
//  Fateconde
//
//  Created by André Roque Matheus on 01/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit

@IBDesignable class PillLabel: UILabel {
    func setup() {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        textAlignment = .center
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let newWidth = superSize.width + superSize.height
        let newHeight = superSize.height
        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }
}
