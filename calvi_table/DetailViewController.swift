//
//  DetailViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 18.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit


class DetailViewController: UIViewController {
    
    var anzeig: String?
    var pictureUrl: String?
    var desc: String?
    var price: Int?
    var location: String?
    var date: Int32?
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    @IBOutlet weak var beschreibung: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
