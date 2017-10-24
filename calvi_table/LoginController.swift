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
    
    
    //@IBOutlet weak var backBtn: UIButton!
    //@IBOutlet weak var logoutBtn: UIButton!
    
    /*@IBAction func backButton(_ sender: Any) {
        
        //go back after login
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        Utils.logoutUser()
        
        cleanUserInfo()
        
        //google
        GIDSignIn.sharedInstance().signOut()
        
        dismiss(animated: true, completion: nil)
        
        //facebook sign out? TODO
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIButton()
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.backgroundColor = UIColor.blue
        
        backBtn.heightAnchor.constraint(equalToConstant: 130).isActive = true
        view.addSubview(backBtn)
        let margins = view.layoutMarginsGuide
        backBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        backBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        backBtn.centerYAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        //backBtn.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 50).isActive = true
        
        
        let v2 = UIView()
        v2.backgroundColor = UIColor.red
        // use auto layout
        v2.translatesAutoresizingMaskIntoConstraints = false
        // add width / height constraints
        v2.addConstraint(NSLayoutConstraint(item: v2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100))
        v2.addConstraint(NSLayoutConstraint(item: v2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100))
        // must add to hirarchy before adding the following constraints
        view.addSubview(v2)
        view.addConstraint(NSLayoutConstraint(item: v2, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 100))
        view.addConstraint(NSLayoutConstraint(item: v2, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
    
        //https://stackoverflow.com/questions/41791052/swift-adding-a-button-programmatically-without-supplying-a-frame-during-initial
        
        

        initGoogleSignInButton()
        initFacebookLoginButton()
        
        positionButtons()
        
        if Utils.getUserToken() != "" {
            showUserProfile()
        }
    }
    
    func showUserProfile() {
        
        let profilePicture = Utils.getUserProfilePicture()
        self.userImage.sd_setImage(with: URL(string: profilePicture))
    }
    
    func positionButtons() {
        
        
        
        
    }
    
    func cleanUserInfo() {
        
        self.userImage.sd_setImage(with: nil)
        self.userName.text = ""
    }
    
    func initGoogleSignInButton() {
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        //let signInButton = GIDSignInButton(frame: CGRect(x: 0,y: 0,width: view.frame.width-32, height: 30))
        let signInButton = GIDSignInButton()
        view.addSubview(signInButton)

        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        //signInButton.colorScheme(style: GIDSignInButtonColorScheme.light)
        
        // Get the superview's layout
        let margins = view.layoutMarginsGuide
        
        //signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        signInButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        //signInButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        signInButton.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: 0).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        //signInButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: 150).isActive = true
        
        //signInButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 100).isActive = true
        //https://stackoverflow.com/questions/33348267/3-views-next-to-each-other-programmatically-constraints
        
    }
    
    func initFacebookLoginButton() {
        
        let loginButton = FBSDKLoginButton(frame: CGRect(x: 0,y: 0,width: view.frame.width-32, height: 30))
        
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
