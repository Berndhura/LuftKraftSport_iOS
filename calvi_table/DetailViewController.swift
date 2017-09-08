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
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    @IBOutlet weak var beschreibung: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if anzeig != nil {
            self.anzeigeTitel.text = anzeig
            self.title = anzeig
        }
        
        if desc != nil {
            self.beschreibung.text = desc
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

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
