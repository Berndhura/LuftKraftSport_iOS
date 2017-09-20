//
//  ChatBubbleData.swift
//  calvi_table
//
//  Created by bernd wichura on 20.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit

enum BubbleDataType: Int{
    case Mine = 0
    case Opponent
}

class ChatBubbleData {
    
    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: NSDate?
    var type: BubbleDataType
    
    // 3. Initialization
    init(text: String?,image: UIImage?,date: NSDate? , type:BubbleDataType = .Mine) {
        // Default type is Mine
        self.text = text
        self.image = image
        self.date = date
        self.type = type
    }
}
