//
//  chatController.swift
//  calvi_table
//
//  Created by bernd wichura on 25.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Alamofire

class ChatViewController: JSQMessagesViewController {
    
    var sender: String = ""
    var articleId: Int64 = 1
    var partnerName: String?
    
    var messages = [JSQMessage]()
    
    //private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
   // private var newMessageRefHandle: FIRDatabaseHandle?
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        
        title = partnerName!
        
        fetchChat()


        // messages from someone else
        //addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
        // messages sent from local sender
        //addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
        //addMessage(withId: senderId, name: "Me", text: "I like to run!")
        // animates the receiving of a new message on the view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = Utils.getUserId()
        self.senderDisplayName = "CONAN"
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        /*let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        */
        //itemRef.setValue(messageItem) // 3
        
        let messageToSend = text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("message: " + messageToSend!)
        
        let userToken = Utils.getUserToken()
        let adId = articleId
        let sender = self.sender
        
        print("userToken: " + userToken)
        print(articleId)
        print(sender)
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/messages?token=\(userToken)&articleId=\(adId)&idTo=\(sender)&message=\(messageToSend!)")
        
        print(url!)
        
        //let message = JSQMessage(senderId: senderId!, displayName: senderDisplayName!, text: text!)
        let message =  JSQMessage(senderId: senderId!, senderDisplayName: senderDisplayName!, date: date!, text: text!)
        
        messages.append(message!)
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                //self.addMessage(withId: senderId, name: "Me", text: text!)
        }
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        } else {
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        //return 17.0
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return 0.0
        } else {
            
            return 17.0
            
        }
    }

    
    func fetchChat() {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/messages/forArticle?token=\(userToken)&sender=\(self.sender)&articleId=\(self.articleId)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }

            self.addtoChat(data: data)
            
        }.resume()
    }
    
    func addtoChat(data: Data) {
        
        DispatchQueue.main.async(execute: {

            let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
            
            for dictionary in json as! [[String: Any]] {
                
                let message = dictionary["message"] as? String
                //print(message!)
                
                let date_org = dictionary["date"] as? Double
                //TODO datum richtig ausgerechnet? wird aber nicht angezeigt
                //print(date!)
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMyyyy")
                dateFormatter.locale = Locale(identifier: "de_DE")
                
                let date = Date(timeIntervalSince1970: (date_org! / 1000.0))
               // return dateFormatter.string(from: date)
                
                //let articleId = dictionary["articleId"] as? Int64
                let chatPartner = dictionary["idFrom"] as? String
                //print(chatPartner!)
                self.addMessage(withId: chatPartner!, name: self.partnerName!, text: message!, date: date)
                
            }
            self.finishReceivingMessage()
        })
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("attachment")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String, date: Date) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            //JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
