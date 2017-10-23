//
//  MessageCell.swift
//  calvi_table
//
//  Created by bernd wichura on 21.09.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
   
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var bild: RoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        //bild.layer.cornerRadius = bild.frame.size.height/2.0
        //bild.setNeedsLayout()
    }
    
  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class RoundImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.frame.size.width / 2.0
        
        self.layer.cornerRadius = radius
        
        let constraint: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0)
        self.addConstraint(constraint)
        
        self.contentMode = UIViewContentMode.scaleAspectFill
    }
}
