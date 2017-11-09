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
    
    let signInButton = GIDSignInButton()
    
    let loginButton = FBSDKLoginButton()
    
    let backBtn = UIButton()
    
    let logoutBtn = UIButton()
    
    let buttonHeight: CGFloat = 30
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor(red: 215/255, green: 233/255, blue: 242/255, alpha: 1.0)
        
        //google sign in button
        initGoogleSignInButton()
        
        //facebook button
        initFacebookLoginButton()

        //back button
        initBackButton()
        
        //logout button
        initLogoutButton()
        
        if Utils.getUserToken() != "" {
            showUserProfile()
        }
    }
    
    func initGoogleSignInButton() {
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.colorScheme = GIDSignInButtonColorScheme.dark
        signInButton.style = GIDSignInButtonStyle.wide
        signInButton.layer.cornerRadius = 4
        
        let margins = view.layoutMarginsGuide
        
        signInButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        view.addSubview(signInButton)
        
        signInButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -4).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 4).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -10).isActive = true
    }
    
    func initFacebookLoginButton() {
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        let margins = view.layoutMarginsGuide
        
        loginButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        
        loginButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        loginButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -10).isActive = true
        
        //if the user is already logged in
        if let _ = FBSDKAccessToken.current(){
            //getFBUserData()
        }
    }
    
    func initBackButton() {
        
        backBtn.addTarget(self, action: #selector(goBackPressed), for: .allTouchEvents)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.backgroundColor = UIColor(colorLiteralRed: 10/250, green: 100/250, blue: 200/250, alpha: 1)
        backBtn.setTitle("Zurück", for: .normal)
        backBtn.layer.cornerRadius = 4
        
        backBtn.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        view.addSubview(backBtn)
        let margins = view.layoutMarginsGuide
        backBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        backBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        backBtn.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -10).isActive = true
    }
    
    func initLogoutButton() {
        
        logoutBtn.addTarget(self, action: #selector(logoutPressed), for: .allTouchEvents)
        
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        logoutBtn.backgroundColor = UIColor(colorLiteralRed: 10/250, green: 100/250, blue: 200/250, alpha: 1)
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.layer.cornerRadius = 4
        
        logoutBtn.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        view.addSubview(logoutBtn)
        let margins = view.layoutMarginsGuide
        logoutBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        logoutBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        logoutBtn.bottomAnchor.constraint(equalTo: backBtn.topAnchor, constant: -10).isActive = true
    }

    func logoutPressed() {
        
        Utils.logoutUser()
        
        cleanUserInfo()
        
        //google
        GIDSignIn.sharedInstance().signOut()
        
        dismiss(animated: true, completion: nil)
        //facebook sign out? TODO
        
        userImage.image = UIImage(named: "account_placeholder")
    }
    
    func goBackPressed() {
        
        //go back after login
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    func showUserProfile() {
        
        let profilePicture = Utils.getUserProfilePicture()
        self.userImage.sd_setImage(with: URL(string: profilePicture))
    }
    
    
    func cleanUserInfo() {
        
        self.userImage.sd_setImage(with: nil)
        self.userName.text = ""
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout from facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        if let accesToken = FBSDKAccessToken.current() {
            print(accesToken)
            
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (conection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }

            //FB access token
            let token = FBSDKAccessToken.current().tokenString
            self.saveUserToken(tokenString: token!)
            
            Utils.updateDeviceToken()
            
            var dict: NSDictionary!
            dict = result as! NSDictionary
            
            self.saveUserName(nameString: dict["name"]! as! String)
            self.saveUserId(idString: dict["id"]! as! String)
            
            if let picture = dict["picture"] as? NSDictionary {
                if let data = picture["data"] as? NSDictionary{
                    if let profilePicture = data["url"] as? String {
                        print(profilePicture)
                        self.saveUsersProfileImage(profileUrl: profilePicture)
                        self.userImage.sd_setShowActivityIndicatorView(true)
                        self.userImage.sd_setIndicatorStyle(.gray)
                        self.userImage.sd_setImage(with: URL(string: profilePicture))
                    }
                }
            }
            let fullName = dict["name"]! as! String
            self.userName.text = "Willkommen " + fullName
        })
    }
    
    func saveUserId(idString: String) {
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(idString, forKey: "userId")
        defaults.synchronize()
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
    
    func saveUsersProfileImage(profileUrl: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(profileUrl, forKey: "userImageUrl")
        defaults.synchronize()
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            
            self.saveUsersProfileImage(profileUrl: user.profile.imageURL(withDimension: 400).absoluteString)
            self.userImage.sd_setImage(with: user.profile.imageURL(withDimension: 400))
            
            let fullName = user.profile.name
            self.userName.text = "Willkommen " + fullName!
            
            saveUserDetails(user: user)
            Utils.updateDeviceToken()
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func saveUserDetails(user: GIDGoogleUser) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(user.authentication.idToken, forKey: "userToken")
        defaults.set(user.userID, forKey: "userId")
    }
}
