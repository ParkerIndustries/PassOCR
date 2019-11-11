//
//  ScopeView.swift
//  PassOCR
//
//  Created by Mickaël on 11/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import UIKit

@IBDesignable
class ScopeView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable
    var border: CGFloat = 3
    
    override func layoutSublayers(of layer: CALayer) {
        
        layer.borderWidth = border
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        super.layoutSublayers(of: layer)
    }
}
