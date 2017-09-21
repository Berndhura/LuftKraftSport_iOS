//
//  MessageController.swift
//  calvi_table
//
//  Created by bernd wichura on 21.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit

class MessageController: ViewController {

}


import UIKit

class MessagesController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults:UserDefaults = UserDefaults.standard
        let userId = defaults.string(forKey: "userId")
        
        print(userId)
        
    }
}
