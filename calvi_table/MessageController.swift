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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMessages()

        //table
        self.tableView.contentInset = UIEdgeInsets(top: -64.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        navigationItem.title = "Messages: " + String(messages.count)
        tableView?.backgroundColor = UIColor.gray
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func getUserToken() -> String {
        //User defaults: userToken
        let defaults:UserDefaults = UserDefaults.standard
        let userId: String? = defaults.string(forKey: "userToken")
        //print("UserToken: " + userId!)
        return userId!
    }
    
    func fetchMessages() {
        
        let userToken = getUserToken()
        
        let defaults:UserDefaults = UserDefaults.standard
        let userId: String? = defaults.string(forKey: "userId")

        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/messages/forUser?token=\(userToken)")
        
        //print(url)
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
            
            print(json)
            
            for dictionary in json as! [[String: Any]] {
                
                let message = dictionary["message"] as? String
                let name = dictionary["name"] as? String
                let urlList = dictionary["url"] as? String
                let url = self.getPictureUrl(str: urlList!)
                let idFrom = dictionary["idFrom"] as? String
                let idTo = dictionary["idTo"] as? String
                let date = dictionary["date"] as? Double
                let articleId = dictionary["articleId"] as? Int64
                let chatPartner = dictionary["chatPartner"] as? String
                
                let msg = MessageOverview(name: name!, message: message!, url: url, date: date!, idFrom: idFrom!, idTo: idTo!, articleId: articleId!, chatPartner: chatPartner!)
                
                //print(ad.urls)
                
                self.messages.append(msg)
            }
            
            self.navigationItem.title = "Messages: " + String(self.messages.count)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
            }.resume()
    }
    
    func getPictureUrl(str: String) -> String {
        let ind = str.characters.split{$0 == ","}.map(String.init)
        if ind.count > 0 {
            return ind[0]
        } else {
            return "1"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChat" {
            let chatController: ChatViewController = (segue.destination as? ChatViewController)!
            let cell: UITableViewCell? = sender as? UITableViewCell
            
            if cell != nil {
                let indexPath: IndexPath? = self.tableView.indexPath(for: cell!)
                if indexPath != nil {
                    let messageElement: MessageOverview = messages[indexPath!.row]
                    chatController.sender = messageElement.chatPartner
                    chatController.articleId = messageElement.articleId
                }
            }
        }
    }
}


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
        //let formatter = DateFormatter()
        //formatter.dateFormat = "dd.MM.yy"
        //let TestDateTime = formatter.date(from: String(describing: currentMessage.date))
        //cell?.date?.text = String(describing: TestDateTime)
        cell?.date?.text = String(describing: NSDate(timeIntervalSince1970: TimeInterval(currentMessage.date)))
    
        //image
        let imageId = messages[indexPath.item].url
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageId)/thumbnail/")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                cell?.bild.image = image
            })
            }.resume()
        
        //TODO  Task vorher entfernen
        cell?.bild.sd_setImage(with: url, placeholderImage: UIImage(named: "taylor_swift_blank_space.jpg"))
        
        return cell!
    }
}


extension MessagesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0//UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 100.0
    }
}
