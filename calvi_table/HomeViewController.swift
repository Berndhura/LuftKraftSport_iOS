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
        showMyArticles()
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
        initMyArticlesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initLoginButton()
        initMyArticlesButton()
    }
    
    
    func initMyArticlesButton() {
        if Utils.getUserToken() == "" {
            if let _ = myArticles {
                myArticles.removeFromSuperview()
            }
        } else {
            if let btn = myArticles {
                view.addSubview(btn)
            }
        }
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
            self.initMyArticlesButton()
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
    
    
    func showMyArticles() {
        if Utils.getUserToken() == "" {
            loginUser()
        } else {
            //call VC with "my articles"
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "mainPage") as! ViewController
            newViewController.callbackClosure = { [weak self] in
                newViewController.showMyArticle()
            }
            self.navigationController?.pushViewController(newViewController, animated: true)
            
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "myArticles"), object: nil)
        }
    }
}
