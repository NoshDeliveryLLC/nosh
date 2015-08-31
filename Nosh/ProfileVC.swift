//
//  ProfileVC.swift
//  Nosh
//
//  Created by Muhammad Javeed on 25/02/2015.
//  Copyright (c) 2015 Nosh. All rights reserved.
//

import Foundation

class ProfileVC: UIViewController{
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = PFUser.currentUser();
        if(user != nil){
            self.userName.text = user?.username
            var nameStr = user["name"] as? String
            self.name.text = nameStr != nil ? nameStr : " "
            var phoneStr = user["phone"] as? String
            self.phone.text = phoneStr != nil ? phoneStr : " "
            self.address.text = Util.getAddress()
        }
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func menuTapped(sender : UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
}
