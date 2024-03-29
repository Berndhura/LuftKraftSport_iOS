//
//  MessageController.swift
//  calvi_table
//
//  Created by bernd wichura on 21.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

class MessagesController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [MessageOverview] = []
    
    var refreshMessages: UIBarButtonItem?
    
    var noMessagesLabel = UILabel()
    
    var isLoadingTableView = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = NSLocalizedString("messages_tab", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // removed: loginseite wird 2 mal gezeigt wenn wenn schon existiert und über tab erneut angewählt wird
        
        /*if isLoggedIn() {
            prepareView()
        } else {
            openLogin()
        }*/
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !isLoggedIn() {
            openLogin()
        } else {
            prepareView()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.title = NSLocalizedString("messages_title", comment: "") + String(self.messages.count)
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshMessages!], animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //if not logged in -> loginVC pops up -> no login and back -> show main VC (index 0)
        if !isLoggedIn() {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    
    func prepareView() {
        
        tableView.separatorStyle = .none
        
        refreshMessages = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(MessagesController.fetchMessages))
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshMessages!], animated: true)
        
        self.tableView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView?.backgroundColor = UIColor.gray
        navigationController?.navigationBar.isTranslucent = true
        
        if !DeviceType.IS_IPHONE_5 {
            tableView.contentInset = UIEdgeInsets.zero
        }
        
        fetchMessages()
    }
    
    
    func openLogin() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    func isLoggedIn() -> Bool {
        
        if Utils.getUserToken() == "" {
            return false
        } else {
            return true
        }
    }
    
    
    func fetchMessages() {
        
        var localMsg: [MessageOverview] = []
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://52.29.200.187:80/api/V3/messages/forUser?token=\(userToken)")
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    let jsonData = JSON(response.result.value ?? "default")
                    var urlImages = ""
                    for (_ , value) in jsonData {
                        
                        let message = value["message"].string
                        let name = value["name"].string
                        if let urlList = value["url"].string {
                            urlImages = Utils.getPictureUrl(str: urlList)
                        } else {
                            urlImages = ""
                        }
                        //let url = Utils.getPictureUrl(str: urlList!)
                        let idFrom = value["idFrom"].string
                        let idTo = value["idTo"].string
                        let date = value["date"].double
                        let articleId = value["articleId"].int64
                        let chatPartner = value["chatPartner"].string
                        
                        let msg = MessageOverview(name: name!, message: message!, url: urlImages, date: date!, idFrom: idFrom!, idTo: idTo!, articleId: articleId!, chatPartner: chatPartner!)
                        
                        localMsg.append(msg)
                    }
                case .failure(let error):
                    print(error)
                }
                self.messages = localMsg
                self.tableView.reloadData()
                //TODO welches ist richtig?
                self.tabBarController?.title = NSLocalizedString("messages_title", comment: "") + String(self.messages.count)
                self.navigationItem.title = NSLocalizedString("messages_title", comment: "") + String(self.messages.count)
        }
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
        
        if messages.count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("no_messages", comment: ""))
        } else {
            self.tableView.restore()
        }
        
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
        let url = URL(string: "http://52.29.200.187:80/api/V3/pictures/\(imageId)/thumbnail/")
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
