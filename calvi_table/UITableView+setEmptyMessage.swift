//
//  UITableView+setEmptyMessage.swift
//  calvi_table
//
//  Created by bernd wichura on 17.10.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation

extension UITableView {
    
    //TODO anzeige wenn kein Internet vorhanden
    //TODO ein richtiges background bild machen, das hier ist nicht so schön
    
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = appMainColorBlue
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Verdana", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.backgroundColor = .white
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
