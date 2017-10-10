//
//  DetailViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 18.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Alamofire
import MapKit


class DetailViewController: UIViewController, MKMapViewDelegate {
    
    var anzeig: String?
    var pictureUrl: String?
    var desc: String?
    var price: Int?
    var location: String?
    var date: Double?
    var userId: String?
    var articleId: Int32?
    var lat: Double?
    var lng: Double?
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var mainPicture: UIImageView!
    @IBOutlet weak var beschreibung: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    

    @IBOutlet weak var bookmarkEditButton: UIButton!
    
    @IBAction func bookmarkEditAction(_ sender: Any) {
        
        let userIdFromDefaults = getUserId()
        
        if userId == userIdFromDefaults {
            editArticle(articleId: articleId!)
        } else {
            bookmarkArticle(articleId: articleId!)
        }
    }
   
    @IBOutlet weak var messageButton: UIButton!
    
    @IBAction func msgDeleteButton(_ sender: Any) {
        
        let userIdFromDefaults = getUserId()
        
        if userId == userIdFromDefaults {
            deleteArticle(articleId: articleId!)
        } else {
            if getUserToken() == "" {
                //not logged in
                let alert = UIAlertController(title: "Nicht angemeldet!", message: "Um Nachrichten zu versenden, musst du dich anmleden.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Schließen", style:.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Anmelden", style: .default, handler: { (action: UIAlertAction!) in
                    //let newViewController = LoginController()
                    //self.navigationController?.pushViewController(newViewController, animated: true)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
                    self.navigationController?.present(newViewController, animated: true, completion: nil)
                    //TODO mach login seite auf aber ohne navigation leider, keine möglichkeit nach login von der seite zu kommen
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                sendMessage(articleId: articleId!, userIdFromArticle: userId!)
            }
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        prepareMap()
        
        if userId != nil {
            let userIdFromDefaults = getUserId()
            if userId == userIdFromDefaults {
                messageButton.setTitle("Löschen" , for: .normal)
                bookmarkEditButton.setTitle("Bearbeiten", for: .normal)
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
        
        //date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let date = Date(timeIntervalSince1970: (self.date! / 1000.0))
        self.dateLabel.text = "Erstellt am: " + dateFormatter.string(from: date)
        
        //location
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
    
    func prepareMap() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        let anno: MKPointAnnotation = MKPointAnnotation()
        if lat != nil && lng != nil {
            anno.coordinate = CLLocationCoordinate2DMake(lat!, lng!)
        }
        anno.title = anzeig
        
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat!, longitude: lng!), span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.isZoomEnabled = true
        
        mapView.addAnnotation(anno)
    }
    
    func editArticle(articleId: Int32) {
        
    }
    
    func bookmarkArticle(articleId: Int32) {
        
        let userToken = getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/bookmark?token=\(userToken)")
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                self.showAlert()
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Artikel ist gemerkt!", message: nil, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    func deleteArticle(articleId: Int32) {
        
        let userToken = getUserToken()
        
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
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func sendMessage(articleId: Int32, userIdFromArticle: String) {
        
        let alertController = UIAlertController(title: "Nachricht schreiben", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Senden", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                
                let message = field.text!
                
                let userToken = self.getUserToken()
                
                let url = URL(string: "http://178.254.54.25:9876/api/V3/messages?token=\(userToken)&articleId=\(articleId)&idTo=\(userIdFromArticle)&message=\(message)")
                
                
                Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
                    .responseJSON { response in
                        debugPrint(response)
                }

            } else {
                //nothing here
            }
        }
        
        let cancelAction = UIAlertAction(title: "Doch nicht", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Sag etwas..."
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func getUserId() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        if let userId = defaults.string(forKey: "userId") {
            return userId
        } else {
            return ""
        }
    }
    
    func getUserToken() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        if let userToken = defaults.string(forKey: "userToken") {
            return userToken
        } else {
            return ""
        }
    }
}
