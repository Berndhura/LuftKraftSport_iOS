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
import SDWebImage


class DetailViewController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate {
    
    var articleTitle: String?
    var pictureUrl: String?
    var desc: String?
    var price: Int?
    var location: String?
    var date: Double?
    var userId: String?
    var articleId: Int32?
    var lat: Double?
    var lng: Double?
    
    var imageCount = 0
    
    var allImagesLoaded = false
    
    var imageNumberList = [String]()
    
    public var myBookmarks: [Int32] = []
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var beschreibung: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func shareArticle(_ sender: Any) {
        
        let originalString = "First Whatsapp Share"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        
        let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
        
        if UIApplication.shared.canOpenURL(url! as URL)
        {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        
        //TODO ???? häääää??? was soll das hier???
    }

    @IBOutlet weak var bookmarkEditButton: UIButton!
    
    @IBAction func bookmarkEditAction(_ sender: Any) {
        
        let userIdFromDefaults = Utils.getUserId()
        
        if userId == userIdFromDefaults {
            //own article -> just edit possible
            editArticle(articleId: articleId!)
        } else {
            //not own article -> bookmark or unbookmark
            if myBookmarks.contains(articleId!) {
                //unbookmark
                unBookmarkArticle(articleId: articleId!)
                bookmarkEditButton.setTitle("Merken", for: .normal)
                removeArticelFromBookmarkList(id: articleId!)
            } else {
                //bookmark this article
                bookmarkArticle(articleId: articleId!)
                bookmarkEditButton.setTitle("Vergessen", for: .normal)
                myBookmarks.append(articleId!)
            }
        }
    }
   
    @IBOutlet weak var messageButton: UIButton!
    
    @IBAction func msgDeleteButton(_ sender: Any) {
        
        let userIdFromDefaults = Utils.getUserId()
        
        if userId == userIdFromDefaults {
            deleteArticle(articleId: articleId!)
        } else {
            if Utils.getUserToken() == "" {
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
        
        imageCount = Utils.getAllPictureUrls(str: pictureUrl!).count
        
        scrollView.delegate = self
        
        prepareMap()
        
        if userId != nil {
            let userIdFromDefaults = Utils.getUserId()
            if userId == userIdFromDefaults {
                messageButton.setTitle("Löschen" , for: .normal)
                bookmarkEditButton.setTitle("Bearbeiten", for: .normal)
            } else {
                //already bookmarked? adapt button title
                if myBookmarks.contains(articleId!) {
                    bookmarkEditButton.setTitle("Vergessen", for: .normal)
                } else {
                    bookmarkEditButton.setTitle("Merken", for: .normal)
                }
            }
        }
        
        if articleTitle != nil {
            self.anzeigeTitel.text = articleTitle
            self.title = articleTitle
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
        
        //configure page controller with number of images
        pageControl.numberOfPages = Utils.getAllPictureUrls(str: pictureUrl!).count
        
        imageNumberList = Utils.getAllPictureUrls(str: pictureUrl!)
        
        prepareScrollView()
        
        //show first image
        addImageToScrollView(imageNumber: 0)
    }

    func prepareScrollView() {
        //resize scrollView to image count
        let imageCount = Utils.getAllPictureUrls(str: pictureUrl!).count
        self.scrollView.contentSize.width = self.scrollView.frame.width * CGFloat(imageCount)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let displayWidth = self.view.frame.width
        
        //print("page: ", Int(scrollView.contentOffset.x / CGFloat(displayWidth)))
        let page = Int(scrollView.contentOffset.x / CGFloat(displayWidth))
        
        //load next image only if not shown or already loaded
        if ((page + 1 < imageCount) && !allImagesLoaded) {
            addImageToScrollView(imageNumber: page + 1)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func addImageToScrollView(imageNumber: Int) {
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageNumberList[imageNumber])")
        let imageView = UIImageView()
        imageView.sd_imageTransition = .fade
        imageView.sd_setImage(with: url!, placeholderImage: nil, options: .progressiveDownload) { (image, error, imageType, url) in
            imageView.contentMode = .scaleAspectFit
            let xPosition = self.view.frame.width * CGFloat(imageNumber)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.width)
            self.scrollView.addSubview(imageView)
            
            //in case last image is downloaded -> stop adding images to scrollview
            if (imageNumber + 1 == self.imageCount) {
                self.allImagesLoaded = true
            }
        }
    }
    
    func prepareMap() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        let anno: MKPointAnnotation = MKPointAnnotation()
        if lat != nil && lng != nil {
            anno.coordinate = CLLocationCoordinate2DMake(lat!, lng!)
        }
        anno.title = articleTitle
        
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat!, longitude: lng!), span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.isZoomEnabled = true
        
        mapView.addAnnotation(anno)
    }
    
    func editArticle(articleId: Int32) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "newArticleController") as! NewAdViewController
        vc.articleId = self.articleId!
        vc.titleFromAd = self.articleTitle!
        vc.descFromAd = self.desc!
        vc.date = self.date!
        vc.lat = self.lat!
        vc.lng = self.lng!
        vc.priceFromAd = self.price!
        vc.locationFromAd = self.location!
        vc.pictureUrl = self.pictureUrl!
        vc.isEditMode = true
        
        navigationController?.pushViewController(vc, animated: true)
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
    
    func bookmarkArticle(articleId: Int32) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/bookmark?token=\(userToken)")
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                self.showAlert()
        }
    }
    
    func unBookmarkArticle(articleId: Int32) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/bookmarks/\(articleId)?token=\(userToken)")
        
        Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                self.showUnBookmarkInfo()
        }
    }
    
    func showUnBookmarkInfo() {
        let alert = UIAlertController(title: "Artikel wird vergessen!", message: nil, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Artikel ist gemerkt!", message: nil, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    func deleteArticle(articleId: Int32) {
        
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
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func sendMessage(articleId: Int32, userIdFromArticle: String) {
        
        let alertController = UIAlertController(title: "Nachricht schreiben", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Senden", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                
                let message = field.text!
                
                let userToken = Utils.getUserToken()
                
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
}
