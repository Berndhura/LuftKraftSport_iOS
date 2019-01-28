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
import SVProgressHUD
import SwiftyJSON


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
    var views: Int?
    
    var isFollowSearchNotification: Bool?
    
    var imageCount = 0
    
    var allImagesLoaded = false
    
    var imageNumberList = [String]()
    
    public var myBookmarks: [Int32] = []
    
    var didLoadContent: Bool = false
    
    var shareButton: UIBarButtonItem?
    
    @IBOutlet weak var anzeigeTitel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var beschreibung: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
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
                bookmarkEditButton.setTitle(NSLocalizedString("remember", comment: ""), for: .normal)
                removeArticelFromBookmarkList(id: articleId!)
            } else {
                //bookmark this article
                if Utils.isLoggedIn() {
                    bookmarkArticle(articleId: articleId!)
                    bookmarkEditButton.setTitle(NSLocalizedString("forget", comment: ""), for: .normal)
                    myBookmarks.append(articleId!)
                } else {
                    showLoginInfo(text: NSLocalizedString("login_to_bookmark", comment: ""))
                }
            }
        }
    }
    
    func showLoginInfo(text: String) {
        let alert = UIAlertController(title: NSLocalizedString("not_logged_in", comment: ""), message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("abort", comment: ""), style:.default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("login_btn", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    @IBOutlet weak var messageButton: UIButton!
    
    @IBAction func msgDeleteButton(_ sender: Any) {
        
        let userIdFromDefaults = Utils.getUserId()
        
        if userId == userIdFromDefaults {
            deleteArticle(articleId: articleId!)
        } else {
            if Utils.getUserToken() == "" {
                //not logged in
                showLoginInfo(text: NSLocalizedString("login_to_message", comment: ""))
            } else {
                sendMessage(articleId: articleId!, userIdFromArticle: userId!)
            }
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        if let _ = isFollowSearchNotification {
            getDetailsForArticle()
        } else {
            showDetails()
        }
    }
    
    
    func showDetails() {
        
        increaseViewsForAd()
        
        imageCount = Utils.getAllPictureUrls(str: pictureUrl!).count
        
        scrollView.delegate = self
        
        prepareMap()
        
        prepareShareButton()
        
        if userId != nil {
            let userIdFromDefaults = Utils.getUserId()
            if userId == userIdFromDefaults {
                messageButton.setTitle(NSLocalizedString("delete", comment: "") , for: .normal)
                bookmarkEditButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
            } else {
                //already bookmarked? adapt button title
                if myBookmarks.contains(articleId!) {
                    bookmarkEditButton.setTitle(NSLocalizedString("forget", comment: ""), for: .normal)
                } else {
                    bookmarkEditButton.setTitle(NSLocalizedString("remember", comment: ""), for: .normal)
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
        self.dateLabel.text = NSLocalizedString("created_on", comment: "") + dateFormatter.string(from: date)
        
        //location
        if location != nil {
            self.locationLabel.text = location
        }
        
        //configure page controller with number of images
        pageControl.numberOfPages = Utils.getAllPictureUrls(str: pictureUrl!).count
        
        imageNumberList = Utils.getAllPictureUrls(str: pictureUrl!)
    }
    
    func getDetailsForArticle() {
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId!)")
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let jsonData = JSON(response.result.value ?? "default")
                
                    self.articleTitle = jsonData["title"].string
                    self.pictureUrl = jsonData["urls"].string
                    self.desc = jsonData["description"].string
                    self.price = jsonData["price"].int
                    self.location = jsonData["location"].string
                    self.date = jsonData["date"].double
                    self.userId = jsonData["userId"].string
                    self.articleId = jsonData["id"].int32
                    self.lat = jsonData["location"]["coordinates"][0].double
                    self.lng = jsonData["location"]["coordinates"][1].double
                    self.views = jsonData["views"].int
                    
                    self.imageNumberList = Utils.getAllPictureUrls(str: self.pictureUrl!)
                    self.prepareScrollView()
                    
                    //show first image
                    self.addImageToScrollView(imageNumber: 0)
                    self.showDetails()
        
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.didLoadContent == false else {
            return
        }
        
        self.didLoadContent = true
        
        if let _ = isFollowSearchNotification {
            //nothing here!  why??
        } else {
            prepareScrollView()
            //show first image
            addImageToScrollView(imageNumber: 0)
        }
    }
    
    
    func prepareShareButton() {
        shareButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(DetailViewController.shareArticle))
        self.navigationItem.setRightBarButton(shareButton, animated: true)
    }

    
    func increaseViewsForAd() {
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId!)/increaseViewCount")
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
        }
    }
    
    
    func shareArticle(_ sender: Any) {
        
        let id = self.articleId!
        let originalString = NSLocalizedString("whatsapp_share", comment: "") + "http://www.luftkraftsport.de/#/article/\(String(describing: id))/show"
        
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        
        let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
           //no Whatsapp - show it
            let alertNoWhatsapp = UIAlertController(title: NSLocalizedString("problem", comment: ""), message: NSLocalizedString("no_whatsapp", comment: ""), preferredStyle: .alert)
            let ok = UIAlertAction(title: "ok", style: .default) { (action) in
                return
            }
            alertNoWhatsapp.addAction(ok)
            present(alertNoWhatsapp, animated: true, completion: nil)
        }
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
        
        if (imageNumberList.count > 0) {
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageNumberList[imageNumber])")
            let imageView = UIImageView()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapImage(_:)))

            imageView.addGestureRecognizer(tapGesture)
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.sd_imageTransition = .fade
            SVProgressHUD.show()
            imageView.sd_setImage(with: url!, placeholderImage: nil, options: .delayPlaceholder) { (image, error, imageType, url) in
                
                let xPosition = self.view.frame.width * CGFloat(imageNumber)
                imageView.frame = CGRect(x: xPosition, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                self.scrollView.addSubview(imageView)
                //in case last image is downloaded -> stop adding images to scrollview
                if (imageNumber + 1 == self.imageCount) {
                    self.allImagesLoaded = true
                }
                SVProgressHUD.dismiss()
            }
        } else {
            //TODO now image, placeholder?
        }
    }
    
    var newImageView = UIImageView()
    
    @objc func tapImage(_ sender: UITapGestureRecognizer) {
        let scrollVw = UIScrollView()
        scrollVw.minimumZoomScale = 1.0
        scrollVw.maximumZoomScale = 6.0
        scrollVw.frame = UIScreen.main.bounds
        
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        //scrollVw.addSubview(newImageView)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let lat = view.annotation?.coordinate.latitude
        let lng = view.annotation?.coordinate.longitude
        
        let url  = URL(string: "comgooglemaps://?saddr=&daddr=\(Float(lat!)),\(Float(lng!))&directionsmode=driving")
        
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            //UIApplication.shared.openURL(URL(string:"https://www.google.com/maps/@42.585444,13.007813,6z")!)
        } else {
            NSLog("Can't use com.google.maps://");
        }
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
                self.showAlert()
        }
    }
    
    func unBookmarkArticle(articleId: Int32) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/bookmarks/\(articleId)?token=\(userToken)")
        
        Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                self.showUnBookmarkInfo()
        }
    }
    
    func showUnBookmarkInfo() {
        let alert = UIAlertController(title: NSLocalizedString("unbookmark_info", comment: ""), message: nil, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("bookmarked_info", comment: ""), message: nil, preferredStyle: .actionSheet)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    func deleteArticle(articleId: Int32) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)?token=\(userToken)")
        
        let refreshAlert = UIAlertController(title: NSLocalizedString("delete_article", comment: ""), message: NSLocalizedString("delete_article_confirm", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("delete_sure", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("abort", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func sendMessage(articleId: Int32, userIdFromArticle: String) {
        
        let alertController = UIAlertController(title: NSLocalizedString("write_message", comment: ""), message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: NSLocalizedString("send", comment: ""), style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                
                let message = field.text!
                
                let userToken = Utils.getUserToken()
                
                let url = URL(string: "http://178.254.54.25:9876/api/V3/messages?token=\(userToken)&articleId=\(articleId)&idTo=\(userIdFromArticle)&message=\(message)")
                
                //TODO crash oft hier beim ersten nachrichten schicken url ist nil
                Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
                    .responseJSON { response in
                }

            } else {
                //nothing here
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("not_sure", comment: ""), style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("say_something", comment: "")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
