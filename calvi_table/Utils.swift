//
//  Utils.swift
//  calvi_table
//
//  Created by bernd wichura on 12.10.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import Foundation

class Utils {
    
    static func getUserToken() -> String {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let userToken = defaults.string(forKey: "userToken") {
            return userToken
        } else {
            return ""
        }
    }
    
    static func getUserId() -> String {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let userId = defaults.string(forKey: "userId") {
            return userId
        } else {
            return ""
        }
    }
    
    static func getUserProfilePicture() -> String {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let userImg = defaults.string(forKey: "userImageUrl") {
            return userImg
        } else {
            return ""
        }
    }

    
    static func logoutUser() {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set("", forKey: "userToken")
        defaults.set("", forKey: "userId")
        defaults.synchronize()
    }
}
