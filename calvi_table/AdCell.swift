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
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var views: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var bild: UIImageView!
    
    @IBOutlet weak var title: UILabel!
   
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    public var articleId: Int32 = 0
    
    public var pictureURL: String = ""
    
    public var desc: String = ""
    
    public var dateRawValue: Double = 0
    
    public var lat: Double?
    
    public var lng: Double?
    
    public var userId: String?  {
        didSet {
            loadProfileImage(userId: userId!)
        }
    }
    
    public var myBookmarks: [Int32] = []
    
    var mainViewController: ViewController?
    
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
            removeArticelFromBookmarkList(id: articleId)
            
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
        //open edit article with articleId
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "newArticleController") as! NewAdViewController
        
        vc.articleId = articleId
        vc.pictureUrl = pictureURL
        vc.titleFromAd = self.title.text!
        vc.descFromAd = self.desc
        vc.date = dateRawValue
        /*if let vc.lat = lat {
            } else {
            
        }*/
        vc.lat = lat!
        //TODO optional, was wenn nicht da?? dann crash hier!
        vc.lng = lng!
        vc.priceFromAd = Utils.getPriceFromTextField(priceString: self.price.text!)
        vc.locationFromAd = location.text!
        vc.isEditMode = true
        
        mainViewController!.navigationController?.pushViewController(vc, animated: true)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadProfileImage(userId: String) {
    
        let userToken = Utils.getUserToken()
        
        self.profileImage.image = UIImage(named: "account_placeholder")
        
        if userToken != "" {
        
            let urlString = Urls.sellerDetails + "\(userId)?token=\(userToken)"
            
            let url = URL(string: Urls.sellerDetails + "\(userId)?token=\(userToken)")
            
            if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
                self.profileImage.image = imageFromCache
                
            } else {
            
            Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    if let result = response.result.value {
                        let jsonResult = result as! NSDictionary
                        //print(jsonResult)
                        
                        //profile picture
                        if let pictureUrl = jsonResult.value(forKey: "profilePictureUrl") as? String {
                            self.profileImage.sd_setImage(with: URL(string: pictureUrl))
                        } else {
                            //no profile picture
                        }
                        
                        //profile name
                        if let name = jsonResult.value(forKey: "name") as? String {
                            self.profileName.text! = name
                        }
                    }
                }
            }
            
        } else {
                
            //TODO: nicht angelmedet, was nun ? API ändern hier! userToken falsch hier
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func removeArticelFromBookmarkList(id: Int32) {
        
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
