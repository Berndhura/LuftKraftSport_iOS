//
//  LoginController.swift
//  calvi_table
//
//  Created by bernd wichura on 11.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Google

class LoginController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let signInButton = GIDSignInButton(frame: CGRect(x:0,y:0,width: 200, height: 50))
        signInButton.center = view.center
        
        view.addSubview(signInButton)

    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //print("userToken: ", user.authentication.idToken)
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            //print(user.profile.imageURL(withDimension: 400))
            
            saveUserDetails(user: user)
            
           
            // Adding an out going chat bubble
            let chatBubbleDataMine = ChatBubbleData(text: "Hey there!!! How are you?   Firebase/Analytics][I-ACS023012] Firebase Analytics enabled Firebase/Analytics][I-ACS023012] Firebase Analytics enabled", image: nil, date: NSDate(), type: .Mine)
            let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 150)
            self.view.addSubview(chatBubbleMine)
            
            // Adding an incoming chat bubble
            let chatBubbleDataOpponent = ChatBubbleData(text: "Fine bro!!! check this out", image:UIImage(named: "taylor_swift_blank_space.jpg"), date: NSDate(), type: .Opponent)
            let chatBubbleOpponent = ChatBubble(data: chatBubbleDataOpponent, startY: chatBubbleMine.frame.maxX + 10)
            self.view.addSubview(chatBubbleOpponent)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func saveUserDetails(user: GIDGoogleUser) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(user.authentication.idToken, forKey: "userId")
        
        //let userId = defaults.object(forKey:"userId") as? [String] ?? [String]()

    }
}
