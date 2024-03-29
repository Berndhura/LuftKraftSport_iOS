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
import SystemConfiguration

class Utils {
    
    static func isLoggedIn() -> Bool {
        
        let userToken = Utils.getUserToken()
        if userToken == "" {
            return false
        } else {
            return true
        }
    }
    
    static func getPriceFromTextField(priceString: String) -> Int {
        
        let ind = priceString.split{$0 == " "}.map(String.init)
        if ind.count > 0 {
            if let price: Int = Int(ind[0]) {
                return price
            } else {
                return 0
            }
        } else {
            return 0
        }
}
    
    static func getPictureUrl(str: String) -> String {
        let ind = str.split{$0 == ","}.map(String.init)
        if ind.count > 0 {
            return ind[0]
        } else {
            return "1"  //TODO was soll passieren wenn keine id existiert
        }
    }
    
    static func getAllPictureUrls(str: String) -> [String] {
        var urlList: [String] = []
        let ind = str.split{$0 == ","}.map(String.init)
        for i in ind {
            urlList.append(i.trimmingCharacters(in: .whitespaces))
        }
        return urlList
    }
    
    
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
    
    static func getUserName() -> String {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let userName = defaults.string(forKey: "userName") {
            return userName
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
    
    static func eraseChatInfo() {
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set("", forKey: "articleId")
        defaults.set("", forKey: "senderId")
        defaults.synchronize()
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

        let url = URL(string: "http://52.29.200.187:80/api/V3/users/sendToken?token=\(userToken)&deviceToken=\(deviceToken ?? "")")
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
               // print(response)
        }
    }
    
    static func getFormatedDate(date: Double) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMyyyy")
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let date = Date(timeIntervalSince1970: (date / 1000.0))
        return dateFormatter.string(from: date)
    }
    
    
    static func saveDeviceFmcToken(fcmToken: String) {
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(fcmToken, forKey: "deviceFcmToken")
        defaults.synchronize()
    }
    
    static func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    struct LastLocation {
        var lat: Double?
        var lng: Double?
        var locationName: String?
    }
    
    static func getLastLocation() -> LastLocation {
    
        var lastLocation = LastLocation(lat: 0.0, lng: 0.0, locationName: "")
        
        let defaults:UserDefaults = UserDefaults.standard
        lastLocation.lat = defaults.double(forKey: Constants.lastLat)
        lastLocation.lng = defaults.double(forKey: Constants.lastLng)
        lastLocation.locationName = defaults.string(forKey: Constants.lastLocationName)
        
        return lastLocation
    }
    
    static func setLastLocation(lat: Double?, lng: Double?) {
        let defaults:UserDefaults = UserDefaults.standard
        if let la = lat {
            defaults.set(la, forKey: Constants.lastLat)
        }
        
        if let ln = lng {
            defaults.set(ln, forKey: Constants.lastLng)
        }
    }
    
    static func setLastLocationName(locationName: String?) {
        let defaults:UserDefaults = UserDefaults.standard
        if let loc = locationName {
            defaults.set(loc, forKey: Constants.lastLocationName)
        }
    }
}
