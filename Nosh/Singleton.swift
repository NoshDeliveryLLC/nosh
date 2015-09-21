//
//  Singleton.swift
//  Nosh
//
//  Created by Michael Kolyadintsev on 21.09.15.
//  Copyright © 2015 Nosh. All rights reserved.
//

import Foundation

class Singleton {
static var instance: Singleton!
    var orderForSummary: PFObject
    
    init() {
        orderForSummary = PFObject.init()
    }
    
    // SHARED INSTANCE
    class func sharedInstance() -> Singleton {
        self.instance = (self.instance ?? Singleton())
        return self.instance
    }
    
    

}
