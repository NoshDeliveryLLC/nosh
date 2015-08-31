//
//  TextField.swift
//  Nosh
//
//  Created by Muhammad Javeed on 06/04/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class TextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        
        var newBounds = bounds
        newBounds.origin.x += padding.left
        newBounds.origin.y += padding.top
        newBounds.size.height -= (padding.top * 2) - padding.bottom
        newBounds.size.width -= (padding.left * 2) - padding.right
        return newBounds
    }
}