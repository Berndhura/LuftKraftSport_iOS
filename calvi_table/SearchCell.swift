//
//  SearchCell.swift
//  calvi_table
//
//  Created by bernd wichura on 21.11.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import Alamofire

protocol SearchCellDelegate: AnyObject {
    func deleteSearch(cell: SearchCell)
}

class SearchCell: UITableViewCell {
    
    weak var delegate: SearchCellDelegate?
    
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    public var searchId: Int16 = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func deleteSearch(_ sender: Any) {
        
        delegate?.deleteSearch(cell: self)
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/searches/\(searchId)?token=\(userToken)")
        
        let refreshAlert = UIAlertController(title: NSLocalizedString("delete_search", comment: ""), message: NSLocalizedString("delete_search_confirm", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("delete_sure", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    //now delete from tableView too
                    NotificationCenter.default.post(name: Notification.Name(Constants.searchDeleted), object: nil)
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("abort", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
