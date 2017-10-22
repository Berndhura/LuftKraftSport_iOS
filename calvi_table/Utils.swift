//
//  Utils.swift
//  calvi_table
//
//  Created by bernd wichura on 12.10.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

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
    
    static func updateDeviceToken() {
        
        let userToken = Utils.getUserToken()
        
        let defaults:UserDefaults = UserDefaults.standard
        let deviceToken = defaults.string(forKey: "deviceFcmToken")

        let url = URL(string: "http://178.254.54.25:9876/api/V3/users/sendToken?token=\(userToken)&deviceToken=\(deviceToken ?? "")")
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
        }
    }
    
    static func saveDeviceFmcToken(fcmToken: String) {
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: "deviceFcmToken")
        defaults.synchronize()
    }
}
