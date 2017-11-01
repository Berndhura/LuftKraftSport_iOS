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
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
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
    
    @IBAction func deleteArticle(_ sender: Any) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)?token=\(userToken)")
        
        let refreshAlert = UIAlertController(title: "Artikel wird gelöscht!", message: "Nix mehr mit verkaufen.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Löschen", style: .default, handler: { (action: UIAlertAction!) in
            Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    debugPrint(response)
                    //return to main list
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func editArticle(_ sender: Any) {
        
        //open edit article wit articleId
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "newArticleController") as! NewAdViewController
        vc.articleId = articleId
        //vc.titleFromAd = self.articleTitle!
        //vc.descFromAd = self.desc!
        //vc.date = self.date
        //vc.lat = self.lat!
        //vc.lng = self.lng!
        //vc.priceFromAd = self.price!
        //vc.locationFromAd = self.location!
        vc.isEditMode = true
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)

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
