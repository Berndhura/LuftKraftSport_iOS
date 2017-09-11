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
            //let idToken = user.authentication.idToken // Safe to send to the server
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            print(user.profile.imageURL(withDimension: 400))
        } else {
            print("\(error.localizedDescription)")
        }
    }
}
