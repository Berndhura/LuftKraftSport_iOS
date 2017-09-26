//
//  AdCell.swift
//  calvi_table
//
//  Created by bernd wichura on 18.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit

class AdCell: UITableViewCell {
    
    
    @IBOutlet weak var bild: UIImageView!
    
    @IBOutlet weak var title: UILabel!
   
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    public var artivleId: Int32!
    
    @IBAction func bookmarkAd(_ sender: Any) {
        print("like this")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
