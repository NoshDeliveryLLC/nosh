//
//  BlueNavigationControler.swift
//  Nosh
//
//  Created by Muhammad Javeed on 06/04/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class BlueNavigationController: UINavigationController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor(hex: "39b2ff", alpha: 1.0)
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "COCOGOOSE", size: 18)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}