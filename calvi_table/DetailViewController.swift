//
//  DetailViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 18.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Alamofire


class DetailViewController: UIViewController {
    
    var anzeig: String?
    var pictureUrl: String?
    var desc: String?
    var price: Int?
    var location: String?
    var date: Int32?
    var userId: String?
    var articleId: Int32?
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    @IBOutlet weak var beschreibung: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBAction func msgDeleteButton(_ sender: Any) {
        
        let userIdFromDefaults = getUserId()
        if userId == userIdFromDefaults {
            deleteArticle(articleId: articleId!)
        } else {
            //sendMessage()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userId != nil {
            let userIdFromDefaults = getUserId()
            if userId == userIdFromDefaults {
                messageButton.setTitle("Löschen" , for: .normal)
                //bookmarkButton.setTitle("Bearbeiten", for: .normal)
            }
        }
        
        if anzeig != nil {
            self.anzeigeTitel.text = anzeig
            self.title = anzeig
        }
        
        if desc != nil {
            self.beschreibung.text = desc
        }

        if price != nil {
            self.priceLabel.text = String(describing: price!) + " €"
        }
        
        if date != nil {
            self.dateLabel.text = "Erstellt am: " + String(describing: NSDate(timeIntervalSince1970: TimeInterval(date!)))
        }
        
        if location != nil {
            self.locationLabel.text = location
        }
        
        if pictureUrl != nil {
            
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(pictureUrl ?? "3797")")
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    let image = UIImage(data: data!)
                    self.mainPicture.image = image
                })
                }.resume()
            //self.mainPicture.sd_setHighlightedImage(with: url)

        }
    }
    
    func deleteArticle(articleId: Int32) {
        
        let userToken = getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)?token=\(userToken)")
        
        let refreshAlert = UIAlertController(title: "Artikel wird gelöscht!", message: "Nix mehr mit verkaufen.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Löschen", style: .default, handler: { (action: UIAlertAction!) in
            Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    debugPrint(response)
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func getUserId() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        let userId: String? = defaults.string(forKey: "userId")
        return userId!
    }
    
    func getUserToken() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        let userToken: String? = defaults.string(forKey: "userToken")
        return userToken!
    }
}
