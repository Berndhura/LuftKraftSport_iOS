//
//  HomeViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 25.09.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var myArticles: UIButton!
    
    @IBAction func myArticlesBtn(_ sender: Any) {
        
    }
    
    @IBOutlet weak var login: UIButton!
    
    @IBAction func loginBtn(_ sender: Any) {
        
        if Utils.getUserToken() == "" {
            loginUser()
        } else {
            logoutUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLoginButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initLoginButton()
    }
    
    func initLoginButton() {
        if Utils.getUserToken() == "" {
            login.setTitle(NSLocalizedString("login_btn", comment: ""), for: .normal)
        } else {
            login.setTitle(NSLocalizedString("logout_btn", comment: ""), for: .normal)
        }
    }
    
    
    func logoutUser() {
        let logoutAlert = UIAlertController(title: NSLocalizedString("confirm_logout_title", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            Utils.logoutUser()
            //google
            GIDSignIn.sharedInstance().signOut()
            //facebook
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            self.initLoginButton()
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(logoutAlert, animated: true, completion: nil)
    }
    
    
    func loginUser() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
        self.navigationController?.present(newViewController, animated: true, completion: nil)
    }
}
