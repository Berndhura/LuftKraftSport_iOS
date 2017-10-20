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
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editArticle(_ sender: Any) {
        
    }
    
    @IBOutlet weak var bild: UIImageView!
    
    @IBOutlet weak var title: UILabel!
   
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    public var articleId: Int32 = 0
    
    public var myBookmarks: [Int32] = []
    
    @IBAction func addBookmark(_ sender: Any) {
     
        let userToken = Utils.getUserToken()
        
        if myBookmarks.contains(articleId) {
            //remove bookmark
            let url = URL(string: "http://178.254.54.25:9876/api/V3/bookmarks/\(articleId)?token=\(userToken)")
            
            Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    //nothing here, if request did not work? show user info!
            }
            bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_outline_white_36pt"), for: .normal)
            removeArticelFromBokkmarkList(id: articleId)
            
        } else {
            //create bookmark
            let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/bookmark?token=\(userToken)")
            
            Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    print(response)
                    // self.showAlert()
            }
            bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_white_36pt"), for: .normal)
            myBookmarks.append(articleId)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func removeArticelFromBokkmarkList(id: Int32) {
        
        var pos: Int = 0
        for i: Int32 in myBookmarks {
            if articleId == i {
                myBookmarks.remove(at: pos)
                return
            } else {
                pos = pos + 1
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Artikel ist gemerkt!", message: nil, preferredStyle: .actionSheet)
       // self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
}
