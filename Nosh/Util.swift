//
//  Util.swift
//  Nosh
//
//  Created by Muhammad Javeed on 24/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class Util{    
    
    class func getAddress() -> String{
        return Util.getAddress(PFUser.currentUser())
    }
    
    class func isDeliverer() -> Bool{
        var user = PFUser.currentUser()
        if(user != nil && user["userRole"] != nil){
            var userRole = user["userRole"] as! PFObject
            return userRole.objectId == Constant.UserRole.DELIVERER
        }
        return false
    }
    
    class func isDelivererMode() -> Bool{
        var user = PFUser.currentUser()
        if(user != nil && user["delivererMode"] != nil){
            return user["delivererMode"].boolValue
        }
        return false
    }
    
    class func getAddress(object: PFObject?) -> String{
        if (object != nil){
            let addressLine1 = object?.valueForKey("addressLine1") as? String
//            let addressLine2 = object?.valueForKey("addressLine2") as? String
//            let city = object?.valueForKey("city") as? String
//            let state = object?.valueForKey("state") as? String
//            let zip = object?.valueForKey("zip") as? String
            
            var address = "" as String
            if(addressLine1?.isEmpty == false){
                address += addressLine1!
            }
//            if(addressLine2?.isEmpty == false){
//                address += " "+addressLine2!
//            }
//            if(city?.isEmpty == false){
//                address += ". "+city!
//            }
//            if(state?.isEmpty == false){
//                address += ", "+state!
//            }
//            if(zip?.isEmpty == false){
//                address += " "+zip!
//            }
            return address
        }
        return ""
    }
    
    class func configure(config: PFConfig){
        Util.configure(config, gms: true)
    }
    
    class func configure(config: PFConfig, gms: Bool){
//        let strip = config["stripe"] as! NSDictionary
//        #if DEBUG
//            Stripe.setDefaultPublishableKey(strip["test_pk"] as? String)
//        #else
//            Stripe.setDefaultPublishableKey(strip["live_pk"] as? String)
//        #endif
        if(gms){
            GMSServices.provideAPIKey("AIzaSyDplreFQyvs_lih-pqcr3vCbi5c9yokv80")
        }
    }
}