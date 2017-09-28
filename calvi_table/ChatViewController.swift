//
//  chatController.swift
//  calvi_table
//
//  Created by bernd wichura on 25.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Alamofire

class ChatViewController: JSQMessagesViewController {
    
    var sender: String = ""
    var articleId: Int64 = 1
    
    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchChat()
        
        // messages from someone else
        addMessage(withId: "foo", name: "Mr.Bolt", text: "I am so fast!")
        // messages sent from local sender
        addMessage(withId: senderId, name: "Me", text: "I bet I can run faster than you!")
        addMessage(withId: senderId, name: "Me", text: "I like to run!")
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    func getUserToken() -> String {
        //User defaults: userToken
        let defaults:UserDefaults = UserDefaults.standard
        let userId: String? = defaults.string(forKey: "userId")
        //print("UserToken: " + userId!)
        return userId!
    }
    
    func fetchChat() {
        
        let userToken = getUserToken()
        
        Alamofire.request("http://178.254.54.25:9876/api/V3/messages/forArticle?token=\(userToken)&sender=\(sender)&articleId=\(articleId)").responseJSON { response in
            
            print(response.result.value)
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "0815" //FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = "CONAN"
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
