//
//  Extension.swift
//  Nosh
//
//  Created by Muhammad Javeed on 13/03/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

extension UIColor {
    
    convenience init(hex:String, alpha:CGFloat) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            let startIndex = cString.startIndex.advancedBy(1)
            cString = cString.substringFromIndex(startIndex)
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIView {

}

extension UIViewController {
    
    func showActivityIndicatory() {
        var container: UIView = UIView()
        container.frame = self.view.frame
        container.center = self.view.center
        container.backgroundColor = UIColor(hex:"FFFFFF", alpha: 0.3)
        
        var loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor(hex:"444444", alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        actInd.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        container.tag = 9999
        self.view.addSubview(container)
        actInd.startAnimating()
    }
    
    func hideActivityIndicator() {
        var container:UIView = self.view.viewWithTag(9999)!
        container.removeFromSuperview()
    }
    
    func showError(title: String, error: NSError){
        if(error.code == kPFErrorConnectionFailed) {
            self.showError(title, message: "The internet connection appears to be offline")
        } else {
            var errorString = error.userInfo["error"] as? String
            if(errorString != nil){
                self.showError(title, message: errorString!)
            } else {
                self.showError(title, message: error.description)
            }
        }
    }
    
    func showError(title: String, message: String){
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func switchRootViewController(identifier: String, animated: Bool, completion: (() -> Void)?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: UIViewController = storyboard.instantiateViewControllerWithIdentifier(identifier) as! UIViewController
        rootViewController.title = identifier
        if animated {
            UIView.transitionWithView(self.view.window!, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                self.view.window!.rootViewController = rootViewController
                UIView.setAnimationsEnabled(oldState)
                }, completion: { (finished: Bool) -> () in
                    if (completion != nil) {
                        completion!()
                    }
            })
        } else {
            self.view.window?.rootViewController = rootViewController
        }
    }
}


