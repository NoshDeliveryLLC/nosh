//
//  OrderTableViewCell.swift
//  Nosh
//
//  Created by Muhammad Javeed on 25/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation
class OrderTableViewCell: PFTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var editStatus: UIButton!
    @IBOutlet weak var accept: UIButton!
}