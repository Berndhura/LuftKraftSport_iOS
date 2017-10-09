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
    
    func initFacebookLoginButton() {
        
        let loginButton = FBSDKLoginButton(frame: CGRect(x:0,y:0,width: 200, height: 50))
        
        //let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height //real screen height
        //let's suppose we want to have 10 points bottom margin
        let newCenterY = screenHeight - loginButton.frame.height - 50
        let newCenter = CGPoint(x: view.center.x, y: newCenterY)
        loginButton.center = newCenter
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        //if the user is already logged in
        if let _ = FBSDKAccessToken.current(){
            //getFBUserData()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout from facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        let accesToken = FBSDKAccessToken.current()
        print(accesToken!)
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture"]).start(completionHandler: { (conection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }

            //FB access token
            let token = FBSDKAccessToken.current().tokenString
            self.saveUserToken(tokenString: token!)
            
            var dict: NSDictionary!
            dict = result as! NSDictionary
            
            self.saveUserName(nameString: dict["name"]! as! String)
            
            if let picture = dict["picture"] as? NSDictionary {
                if let data = picture["data"] as? NSDictionary{
                    if let profilePicture = data["url"] as? String {
                        print(profilePicture)
                        self.userImage.sd_setShowActivityIndicatorView(true)
                        self.userImage.sd_setIndicatorStyle(.gray)
                        self.userImage.sd_setImage(with: URL(string: profilePicture))
                    }
                }
            }
        })
    }
    
    func saveUserName(nameString: String) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(nameString, forKey: "userName")
    }
    
    func saveUserToken(tokenString: String) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(tokenString, forKey: "userToken")
        defaults.synchronize()
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
        
        //go back
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    func saveUserDetails(user: GIDGoogleUser) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(user.authentication.idToken, forKey: "userToken")
        defaults.set(user.userID, forKey: "userId")
    }
}
