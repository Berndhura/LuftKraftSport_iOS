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
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
