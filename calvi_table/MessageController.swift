//
//  MessageController.swift
//  calvi_table
//
//  Created by bernd wichura on 21.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import SDWebImage

class MessagesController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [MessageOverview] = []
    
    var refreshMessages: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerObservers()
        
        refreshMessages = UIBarButtonItem(image: UIImage(named: "loading"), style: .plain, target: self, action: #selector(MessagesController.fetchMessages))
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshMessages!], animated: true)
        
        if isLoggedIn() {
        
            fetchMessages()

            //table
            self.tableView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
            self.tableView.dataSource = self
            self.tableView.delegate = self
            
            //navigationItem.title = "Messages: " + String(messages.count)
            
            //navigationController?.hidesBarsOnSwipe = true
            
            tableView?.backgroundColor = UIColor.gray
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.title = "Messages: " + String(self.messages.count)
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshMessages!], animated: true)
        
        NotificationCenter.default.removeObserver(self)
        
        if isLoggedIn() {
            fetchMessages()
        }
    }
    
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNewMessage), name: NSNotification.Name(rawValue: Constants.gotPushNotification), object: nil)
    }
    
    
    func showNewMessage() {
        print("angekommen")
    }
    
    func isLoggedIn() -> Bool {
        
        if Utils.getUserToken() == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(newViewController, animated: true)
            return false
        } else {
            //user in
            return true
        }
    }
    
    func fetchMessages() {
        
        print("fetching messages.............")
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/messages/forUser?token=\(userToken)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            
            //TODO fals falscher user - crash hier! NSArray vs NSDictionary wie?
            //let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            
           // let jsonString = String(describing: jsonDictionary)
            
          //  if jsonString.contains("Unauthorized") {
                //nothing here TODO show info to user - unauthorized
           // } else {
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
            //print(json)
            
            //clear messages
            self.messages.removeAll()
            
                for dictionary in json as! [[String: Any]] {
                    
                    let message = dictionary["message"] as? String
                    let name = dictionary["name"] as? String
                    let urlList = dictionary["url"] as? String
                    let url = Utils.getPictureUrl(str: urlList!)
                    let idFrom = dictionary["idFrom"] as? String
                    let idTo = dictionary["idTo"] as? String
                    let date = dictionary["date"] as? Double
                    let articleId = dictionary["articleId"] as? Int64
                    let chatPartner = dictionary["chatPartner"] as? String
                    
                    let msg = MessageOverview(name: name!, message: message!, url: url, date: date!, idFrom: idFrom!, idTo: idTo!, articleId: articleId!, chatPartner: chatPartner!)
                    
                    //print(message)
                    self.messages.append(msg)
                }
          //  }
            
            self.navigationItem.title = "Messages: " + String(self.messages.count)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.tabBarController?.title = "Messages: " + String(self.messages.count)
            })
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChat" {
            let chatController: ChatViewController = (segue.destination as? ChatViewController)!
            let cell: UITableViewCell? = sender as? UITableViewCell
            tabBarController?.title = ""
            
            if cell != nil {
                let indexPath: IndexPath? = self.tableView.indexPath(for: cell!)
                if indexPath != nil {
                    self.navigationItem.title = ""
                    let messageElement: MessageOverview = messages[indexPath!.row]
                    chatController.sender = messageElement.chatPartner
                    chatController.articleId = messageElement.articleId
                    chatController.partnerName = messageElement.name
                }
            }
        }
    }
}

//let imageCache = NSCache<NSString, UIImage>()

extension MessagesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: MessageCell? = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
        
        if cell == nil {
            cell = MessageCell(style: .default, reuseIdentifier: "MessageCell")
        }
        
        let currentMessage: MessageOverview = messages[indexPath.row]
        
        //name
        cell?.name?.text = currentMessage.name
        
        //message
        cell?.message?.text = currentMessage.message
        
        //date
        cell?.date?.text = getFormatedDate(date: currentMessage.date)
    
        //image
        let imageId = messages[indexPath.item].url
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageId)/thumbnail/")
        cell?.bild.sd_setImage(with: url!, placeholderImage: UIImage(named: "lks_logo_1024x1024"))
        
        return cell!
    }
    
    func getFormatedDate(date: Double) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMdd")
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let date = Date(timeIntervalSince1970: (date / 1000.0))
        return dateFormatter.string(from: date)
    }
}


extension MessagesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        return screenHeight / 5.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 100.0
    }
}
