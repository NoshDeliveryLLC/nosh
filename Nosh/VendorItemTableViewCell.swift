//
//  VendorItemTableViewCell.swift
//  Nosh
//
//  Created by Muhammad Javeed on 28/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class VendorItemTableViewCell: PFTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var cartButton: UIButton!
}