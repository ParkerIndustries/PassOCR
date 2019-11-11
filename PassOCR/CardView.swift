//
//  CardView.swift
//  PassOCR
//
//  Created by Mickaël on 11/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

    override func layoutSublayers(of layer: CALayer) {
        layer.cornerRadius = 10
        layer.borderWidth = 0
        layer.shadowOffset = .init(width: 2, height: -2)
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        layer.shadowRadius = 3
        super.layoutSublayers(of: layer)
    }
}
