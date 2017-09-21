//
//  MessageController.swift
//  calvi_table
//
//  Created by bernd wichura on 21.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit

class MessagesController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //User defaults: userToken
        let defaults:UserDefaults = UserDefaults.standard
        let userId: String? = defaults.string(forKey: "userId")
        print("UserToken: " + userId!)
        
        //dummydata
        
        let msg1 = Message(name: "Maul1")
        let msg2 = Message(name: "Maul2")
        let msg3 = Message(name: "Maul3")
        let msg4 = Message(name: "Maul4")
        let msg5 = Message(name: "Maul5")
        
        messages.append(msg1)
        messages.append(msg2)
        messages.append(msg3)
        messages.append(msg4)
        messages.append(msg5)
        
        //table
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: -64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
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
        
        let currentMessage: Message = messages[indexPath.row]
        
        //title
        cell?.name?.text = currentMessage.name
        
        /*
        //description
        cell?.desc?.text = currentAd.desc
        
        //image
        let imageId = getPictureUrl(str: ads[indexPath.item].urls)
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageId)/thumbnail")
        
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
 */
        
        return cell!
    }
}

extension MessagesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 15
    }
}
