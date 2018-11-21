//
//  SearchCell.swift
//  calvi_table
//
//  Created by bernd wichura on 21.11.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func deleteSearch(_ sender: Any) {
        print("delete search")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
