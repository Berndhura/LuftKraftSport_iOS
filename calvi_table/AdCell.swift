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
   
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBAction func bookmarkAd(_ sender: Any) {
        print("like this")
    }
    
    public var artivleId: Int32!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
