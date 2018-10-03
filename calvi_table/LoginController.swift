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

class LoginController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var userImage: RoundImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var mainLoginTitle: UITextView!
    
    let googleSignInBtn = UIButton()
    
    let facebookLoginBtn = UIButton()
    
    let backBtn = UIButton()
    
    let buttonHeight: CGFloat = 30
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshTabBar()
        
        setMainLoginTitle()
        userImage.image = UIImage(named: "lks_logo_1024x1024")
        userImage.hasBorder(false)
        
        //back button
        initBackButton()
        
        //google sign in button
        initGoogleSignInButton()
        
        //facebook button
        initFacebookLoginButton()
        
        if Utils.getUserToken() != "" {
            showUserProfile()
        }
        
        if Utils.getUserToken() != "" {
            hideLoginButtons()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        refreshTabBar()
    }
    
    
    func setMainLoginTitle() {
        if Utils.getUserToken() == "" {
            mainLoginTitle.text = NSLocalizedString("login_main_title", comment: "")
            mainLoginTitle.textColor = appMainColorBlue
            mainLoginTitle.font = UIFont(name: "Verdana", size: 18)
            mainLoginTitle.isHidden = false
        } else {
            mainLoginTitle.isHidden = true
        }
    }
    
    func refreshTabBar() {
        //show user name
        tabBarController?.title = ""
        
        if Utils.getUserToken() == "" {
            tabBarController?.title = "Bitte anmelden!"
        } else {
            tabBarController?.title = "Angemeldet"
        }
        
        //remove tabbar items
        self.tabBarController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    
    func initFacebookLoginButton() {
        
        facebookLoginBtn.addTarget(self, action: #selector(facebookLogin), for: .touchDown)
        facebookLoginBtn.translatesAutoresizingMaskIntoConstraints = false
        facebookLoginBtn.backgroundColor = appMainColorBlue
        facebookLoginBtn.setTitle(NSLocalizedString("login_facebook_button_text", comment: ""), for: .normal)
        facebookLoginBtn.layer.cornerRadius = 4
        view.addSubview(facebookLoginBtn)
        
        let margins = view.layoutMarginsGuide
        facebookLoginBtn.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        facebookLoginBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        facebookLoginBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        facebookLoginBtn.bottomAnchor.constraint(equalTo: googleSignInBtn.topAnchor, constant: -10).isActive = true
    }
    
    
    func initGoogleSignInButton() {
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        googleSignInBtn.addTarget(self, action: #selector(googleLogin), for: .touchDown)
        googleSignInBtn.translatesAutoresizingMaskIntoConstraints = false
        googleSignInBtn.backgroundColor = appMainColorBlue
        googleSignInBtn.setTitle(NSLocalizedString("login_google_button_text", comment: ""), for: .normal)
        googleSignInBtn.layer.cornerRadius = 4
        view.addSubview(googleSignInBtn)
    
        let margins = view.layoutMarginsGuide
        googleSignInBtn.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        googleSignInBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        googleSignInBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        googleSignInBtn.bottomAnchor.constraint(equalTo: backBtn.topAnchor, constant: -10).isActive = true
        
    }
    
    
    func initBackButton() {
        
        backBtn.addTarget(self, action: #selector(goBackPressed), for: .allTouchEvents)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.backgroundColor = appMainColorBlue
        backBtn.setTitle(NSLocalizedString("login_go_back", comment: ""), for: .normal)
        backBtn.layer.cornerRadius = 4
        
        backBtn.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        view.addSubview(backBtn)
        let margins = view.layoutMarginsGuide
        backBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        backBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        backBtn.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -10).isActive = true
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
        
        let profileName = Utils.getUserName()
        self.userName.text = "Willkommen " + profileName
    }
    
    
    func cleanUserInfo() {
        self.userImage.sd_setImage(with: nil)
        self.userName.text = ""
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
    }
    
    
    func facebookLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            self.getFacebookUserInfos()
        }
    }
    
    
    func getFacebookUserInfos() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start(completionHandler: { (conection, result, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let token = FBSDKAccessToken.current().tokenString
            self.saveUserToken(tokenString: token!)
            
            Utils.updateDeviceToken()
            
            var dict: NSDictionary!
            dict = result as? NSDictionary
            
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
            self.refreshTabBar()
            self.hideLoginButtons()
            self.setMainLoginTitle()
        })
    }
    
    
    func googleLogin() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            
            self.saveUsersProfileImage(profileUrl: user.profile.imageURL(withDimension: 400).absoluteString)
            self.userImage.sd_setImage(with: user.profile.imageURL(withDimension: 400))
            
            let fullName = user.profile.name
            self.userName.text = "Willkommen " + fullName!
            
            saveUserDetails(user: user)
            Utils.updateDeviceToken()
            
            self.refreshTabBar()
            
            hideLoginButtons()
            
            setMainLoginTitle()
            
        } else {
            print("\(error.localizedDescription)")
        }
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
    
    
    func hideLoginButtons() {
        
        googleSignInBtn.isHidden = true
        facebookLoginBtn.isHidden = true
    }
    
    
    func showLoginButtons() {
        
        googleSignInBtn.isHidden = false
        facebookLoginBtn.isHidden = false
    }

    
    func saveUserDetails(user: GIDGoogleUser) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(user.authentication.idToken, forKey: "userToken")
        defaults.set(user.userID, forKey: "userId")
        defaults.set(user.profile.name, forKey: "userName")
    }
}
