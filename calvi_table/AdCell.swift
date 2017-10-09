//
//  AdCell.swift
//  calvi_table
//
//  Created by bernd wichura on 18.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Alamofire

class AdCell: UITableViewCell {
    
    
    @IBOutlet weak var bild: UIImageView!
    
    @IBOutlet weak var title: UILabel!
   
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    public var articleId: Int32 = 0
    
    @IBAction func addBookmark(_ sender: Any) {
        
        let userToken = getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/bookmark?token=\(userToken)")
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
               // self.showAlert()
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func getUserToken() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        if let userToken = defaults.string(forKey: "userToken") {
            return userToken
        } else {
            return ""
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Artikel ist gemerkt!", message: nil, preferredStyle: .actionSheet)
       // self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
}
