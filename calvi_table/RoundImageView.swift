//
//  RoundImageView.swift
//  calvi_table
//
//  Created by bernd wichura on 24.09.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation

class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.frame.size.width / 2.0
        self.layer.cornerRadius = radius
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.layer.borderWidth = 1
        
        
        let constraint: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0)
        
        self.addConstraint(constraint)
        
        self.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    func hasBorder(_ border: Bool) {
        if border {
            self.layer.borderWidth = 1
        } else {
            self.layer.borderWidth = 0
        }
    }
}
