//
//  LoginController.swift
//  calvi_table
//
//  Created by bernd wichura on 11.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Google
import FacebookLogin
import FBSDKLoginKit

class LoginController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initGoogleSignInButton()
        initFacebookLoginButton()
    }
    
    func initFacebookLoginButton() {
        
        let loginButton = FBSDKLoginButton(frame: CGRect(x:0,y:0,width: 200, height: 50))
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height //real screen height
        //let's suppose we want to have 10 points bottom margin
        let newCenterY = screenHeight - loginButton.frame.height - 50
        let newCenter = CGPoint(x: view.center.x, y: newCenterY)
        loginButton.center = newCenter
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        
        //if the user is already logged in
        if let _ = FBSDKAccessToken.current(){
            //getFBUserData()
        }
    }
    
    func initGoogleSignInButton() {
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let signInButton = GIDSignInButton(frame: CGRect(x:0,y:0,width: 200, height: 50))
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height //real screen height
        //let's suppose we want to have 10 points bottom margin
        let newCenterY = screenHeight - signInButton.frame.height - 120
        let newCenter = CGPoint(x: view.center.x, y: newCenterY)
        signInButton.center = newCenter
        view.addSubview(signInButton)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logoug facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("facebooook yeahhhhh")
        print(error)
        print(result)
    }
    
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            
            self.userImage.sd_setImage(with: user.profile.imageURL(withDimension: 400))
            
            let fullName = user.profile.name
            self.userName.text = "Willkommen " + fullName!
            
            saveUserDetails(user: user)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func saveUserDetails(user: GIDGoogleUser) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(user.authentication.idToken, forKey: "userToken")
        defaults.set(user.userID, forKey: "userId")
        
        //let userId = defaults.object(forKey:"userId") as? [String] ?? [String]()
    }
}
