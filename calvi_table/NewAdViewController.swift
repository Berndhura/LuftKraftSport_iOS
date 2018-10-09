//
//  NewAdControllerViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 02.10.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import AddressBookUI
import RxSwift
import SVProgressHUD
import SDWebImage
import PromiseKit

class NewAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    public var articleId: Int32 = 0
    public var isEditMode: Bool = false
    public var titleFromAd: String = ""
    public var descFromAd: String = ""
    public var priceFromAd: Int = 0
    public var pictureUrl: String = ""
    public var locationFromAd: String = ""
    public var date: Double = 0.0
    public var lat: Double = 0.0
    public var lng: Double = 0.0
    
    var isLocationChanged = false
    
    var newImagesAdded = false
    
    var locationManager: CLLocationManager!
    
    var locValue: CLLocationCoordinate2D?

    let gapSize: CGFloat = 5
    
    fileprivate let presenter = ArticlePresenter()
    
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextViewFixed!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var saveArticleButton: UIButton!
    
    @IBAction func saveNewAd(_ sender: Any) {
        if isEditMode {
            saveArticleButton.isEnabled = false
            
            if validateInput() {
                updateArticle()
            } else {
                showUselessInfo()
            }
        } else {
            saveArticleButton.isEnabled = false
            
            if validateInput() {
                presenter.getLatLng(address: location.text!, locValue: locValue)
            } else {
                showUselessInfo()
            }
        }
    }
    
    var adButtonViews = [UIButton]()
    
    var adImages = [UIImage]()
    
    var imagesToDelete = [String]()
    
    //holds imageId for corresponding position (key)
    var imageIdDict : [Int: String] = [:]
    
    var currentImageView: UIImageView?
    
    var currentImageNumber: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if isLoggedIn() {
            prepareView()
        } else {
            openLogin()
        }
    }
    
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !isLoggedIn() {
            openLogin()
        } else {
            prepareView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //if not logged in -> loginVC pops up -> no login and back -> show main VC (index 0)
        if !isLoggedIn() {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func prepareView() {
        
        presenter.attachView(self)
        
        initLocationManager()
        
        presenter.init_data(pictureUrl: pictureUrl, isEditMode: isEditMode)
        
        descriptionText.delegate = self
        titleText.delegate = self
        price.delegate = self
        location.delegate = self
        
        initImageIdDict()
        
        location.returnKeyType = UIReturnKeyType.send
        
        location.addTarget(self, action: #selector(NewAdViewController.locationDidChange(_:)), for: UIControlEvents.editingChanged)
        titleText.addTarget(self, action: #selector(NewAdViewController.titleDidChange(_:)), for: .editingDidEnd)
        price.addTarget(self, action: #selector(NewAdViewController.priceDidChange(_:)), for: .editingDidEnd)
        
        if isEditMode {
            saveArticleButton.setTitle(NSLocalizedString("new_article_save_changes_button", comment: ""), for: .normal)
            print("GERO: PictureURL:" + pictureUrl)
            editArticle()
        } else {
            saveArticleButton.setTitle(NSLocalizedString("new_article_save_button", comment: ""), for: .normal)
            setupImagesPlaceholder()
            prepareForms()
        }
    }
    
    
    func initLocationManager() {
        
        locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO in NewAdVC oder ViewController oder app Delegate?
        locValue = manager.location?.coordinate
        //print("locationSAU = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    @objc func locationDidChange(_ textField: UITextField) {
        isLocationChanged = true
    }
    
    @objc func titleDidChange(_ textField: UITextField) {
        guard let string = textField.text else { return }
        
        if (string.isEmpty || string.count < 5) {
            titleText.layer.borderColor = UIColor.red.cgColor
            titleText.layer.borderWidth = 1.0
        }
        if (!string.isEmpty || string.count > 5) {
            titleText.layer.borderColor = UIColor.green.cgColor
            titleText.layer.borderWidth = 1.0
        }
    }
    
   
    @objc func priceDidChange(_ textField: UITextField) {
        guard let string = textField.text else { return }
        
        if (string.isEmpty) {
            price.layer.borderColor = UIColor.red.cgColor
            price.layer.borderWidth = 1.0
        }
        if (!string.isEmpty) {
            price.layer.borderColor = UIColor.green.cgColor
            price.layer.borderWidth = 1.0
        }
    }
    
    
    func initImageIdDict() {
        let imageIds:[String] = Utils.getAllPictureUrls(str: pictureUrl)
        var i = 0
        for id in imageIds {
            imageIdDict[i] = id
            i+=1
        }
    }
    
    
    func isLoggedIn() -> Bool {
        
        if Utils.getUserToken() == "" {
            return false
        } else {
            return true
        }
    }
    
    func openLogin() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
        self.navigationController?.present(newViewController, animated: false)
    }
    
    func refreshTabBar() {
        self.tabBarController?.title = NSLocalizedString("new_article_tab_bar_title", comment: "")
        //remove tabbar items
        self.tabBarController?.navigationItem.setRightBarButtonItems([], animated: true)
    }
    
    func setupImagesPlaceholder() {
        for i in 0...4 {
            imagePlaceholder(imageNumber: i)
        }
    }
    
    
    func imagePlaceholder(imageNumber: Int) {
        let imageButton = UIButton()
        imageButton.setBackgroundImage(UIImage(named: "image_placeholder"), for: .normal)
        imageButton.tag = imageNumber
        imageButton.addTarget(self, action: #selector(imageTapped), for: .allTouchEvents)
        imageButton.contentMode = .scaleToFill
        imageButton.isUserInteractionEnabled = true
        imageButton.layer.cornerRadius = 20
        imageButton.layer.masksToBounds = true
        
        //imgScrollView.translatesAutoresizingMaskIntoConstraints = false
        //let height = (ScreenSize.SCREEN_WIDTH - 4 * gapSize) / 2
        //imgScrollView.contentSize.height = 400//height
        
        
        let xPosition = self.imgScrollView.frame.height * CGFloat(imageNumber) + (gapSize * CGFloat(imageNumber + 1))
        imageButton.frame = CGRect(x: xPosition  , y: 0, width: imgScrollView.frame.height, height: imgScrollView.frame.height)
        
        imgScrollView.contentSize.width = imgScrollView.frame.height * CGFloat(imageNumber + 1) + (gapSize * CGFloat(imageNumber + 1))
        imgScrollView.addSubview(imageButton)
        adButtonViews.append(imageButton)
    }
    
    
    func imageTapped(sender: UIButton) {
        //which image is clicked
        currentImageNumber = sender.tag
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func deleteBtnTapped(sender: UIButton) {
        let imageNumber = imageIdDict[sender.tag]
        
        //remove image from view
        sender.removeFromSuperview()
        let subViews = imgScrollView.subviews
        for subView in subViews {
            if subView.tag == sender.tag {
                //subView.removeFromSuperview()
                subView.alpha = 0.3
            }
        }
        //add image number to list for delete
        imagesToDelete.append(imageNumber!)
        self.pictureUrl = presenter.deleteImageIdFromList(imageId: Int(imageNumber!)!)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //add new images to adImages and adapt list for existing images
        if isEditMode {
            let urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
            
            if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                adButtonViews[currentImageNumber].setImage(chosenImage, for: .normal)
            }
            
            adImages.append((info[UIImagePickerControllerOriginalImage] as? UIImage)!)
            
            //only for existing images
            if (currentImageNumber < urlList.count) {
                let imageNumber = imageIdDict[currentImageNumber]
                imagesToDelete.append(imageNumber!)
                self.pictureUrl = presenter.deleteImageIdFromList(imageId: Int(imageNumber!)!)
                //new image was added -> show new placeholder
            } else {
                imagePlaceholder(imageNumber: currentImageNumber + 1)
            }
        } else {
            //just add new images to adImages list for a new ad
            if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                adButtonViews[currentImageNumber].setImage(chosenImage, for: .normal)
                adImages.append(chosenImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.returnKeyType == UIReturnKeyType.send) {
            // tab forward logic here
            if isEditMode {
                if validateInput() {
                    self.saveArticleButton.isEnabled = false
                    updateArticle()
                } else {
                    showUselessInfo()
                }
            } else {
                if validateInput() {
                    presenter.getLatLng(address: location.text!, locValue: locValue)
                } else {
                    showUselessInfo()
                }
            }
        }
        return true
    }
    
    
    func editArticle() {
        
        //for space on left side
        let leftView = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftView.backgroundColor = .clear
        titleText.leftView = leftView
        titleText.leftViewMode = .always
        titleText.contentVerticalAlignment = .center
        titleText.text = titleFromAd
        
        //description
        descriptionText.text = descFromAd
        
        //price
        let leftViewPrice = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftViewPrice.backgroundColor = .clear
        price.leftView = leftViewPrice
        price.leftViewMode = .always
        price.contentVerticalAlignment = .center
        price.text = String(describing: priceFromAd)
        
        //location
        let leftViewLoc = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftViewLoc.backgroundColor = .clear
        location.leftView = leftViewLoc
        location.leftViewMode = .always
        location.contentVerticalAlignment = .center
        location.text = locationFromAd
        
        //get all image urls and load images
        let urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
        showPictures(urlList: urlList)
    }
    
    func showPictures(urlList: [String]) {
        
        for i in 0..<urlList.count {
            
            let imageButton = UIButton()
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(urlList[i])")
            imageButton.sd_setImage(with: url!, for: .normal, completed: nil)
            imageButton.tag = i
            imageButton.addTarget(self, action: #selector(imageTapped), for: .touchDown)
            imageButton.contentMode = .scaleToFill
            imageButton.isUserInteractionEnabled = true
            imageButton.layer.cornerRadius = 20
            imageButton.layer.masksToBounds = true
            
            let xPosition = self.imgScrollView.frame.height * CGFloat(i) + (gapSize * CGFloat(i + 1))
            imageButton.frame = CGRect(x: xPosition, y: 0, width: imgScrollView.frame.height, height: imgScrollView.frame.height)
            
            imgScrollView.contentSize.width = imgScrollView.frame.height * CGFloat(i + 1) + (gapSize * CGFloat(i + 1))
            imgScrollView.addSubview(imageButton)
            adButtonViews.append(imageButton)
            
            imgScrollView.addSubview(deleteButton(tag: i, xPosition: xPosition))
        }
        
        //one more image placeholder to upload new images
        if (urlList.count < 5) {
            imagePlaceholder(imageNumber: urlList.count)
        }
    }
    
    func deleteButton(tag: Int, xPosition: CGFloat) -> UIButton {
        let deleteBtn = UIButton()
        deleteBtn.setImage(#imageLiteral(resourceName: "delete_icon_white"), for: .normal)
        let imgHight = imgScrollView.frame.height / 4
        let xPosDelBtn = xPosition + 3 * imgHight
        deleteBtn.frame = CGRect(x: xPosDelBtn, y: 0, width: imgHight, height: imgHight)
        deleteBtn.tag = tag
        deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchDown)
        return deleteBtn
    }
    
    func getNewLocationDetails() {
        if let address = location.text {
            CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error as Any)
                    return
                    //TODO was im fehlerfall, default lat lng ? speichern darf nicht abbrechen deshalb
                }
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    self.lat = (location?.coordinate.latitude)!
                    self.lng = (location?.coordinate.longitude)!  //coordinate!.latitude, coordinate!.longitude
                }
            })
        } else {
            //location Nil
            //TODO what now with location?
            //lat lng????
        }
    }
    
    
    func updateArticle() {
        
        if isLocationChanged {
            getNewLocationDetails()
        }
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        self.deleteImageFromListAndServer()
        
        let newPictureUrls = self.pictureUrl
        
        self.uploadNewImagesToAd()
        
        var params = [
            "id": self.articleId,
            "price": self.price.text! as Any,
            "title": self.titleText.text! as Any,
            //no image changes/edits/delete -> only use old ones
            //if URLs string is empty do not set URLS -> URLs are NULL
            "urls" : ((newPictureUrls != "") ? newPictureUrls as Any : nil),
            "description": self.descriptionText.text! as Any
            ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [lat, lng]]
        
        SVProgressHUD.show(withStatus: NSLocalizedString("new_article_change_button", comment: ""))
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                
                SVProgressHUD.dismiss()
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarController
        }
    }
    
    /**
     Uploads all images from adImages to server
     Uses the presenter and PromiseKit
     
     Returns: nothing
     */
    func uploadNewImagesToAd() {
        let userToken = Utils.getUserToken()
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
        print("new images anzahl: ")
        print(adImages.count)
        
        when(fulfilled: adImages.map {presenter.uploadImagePromise(url: url!, image: $0)})
            .done { ([Any]) in
                //und nu
            }.catch { error in
                print(error)
        }
    }
    
    func deleteImageFromListAndServer() {
        for img in imagesToDelete {
            let id = Int(img)
            presenter.deleteImage(articleId: articleId, imageId: id!)
        }
    }
    
    func createNewAd(coordinate: CLLocationCoordinate2D) {
        
        //TODO each post request gets it's own progress: create, edit, picture upload etc
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        let price = self.price.text!
        
        var params = [
            "price": String(price)! as Any,
            "title": titleText.text! as Any,
            "description": descriptionText.text
            ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [coordinate.latitude, coordinate.longitude]]
        
        SVProgressHUD.show(withStatus: NSLocalizedString("new_article_create_ad", comment: ""))
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                SVProgressHUD.dismiss()
                self.uploadImagesForNewAd(response: response)
        }
    }
    
    func validateInput() -> Bool {
    
        if (titleText.text!.isEmpty ||
            descriptionText.text!.isEmpty ||
            price.text!.isEmpty) {
            return false
        } else {
            return true
        }
    }
    
    func uploadImagesForNewAd(response: DataResponse<Any>) {
        
        //get new ID from response
        var dict: NSDictionary!
        dict = response.result.value as! NSDictionary
        
        if let articleId = dict["id"] {
            let userToken = Utils.getUserToken()
            let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
            
            when(fulfilled: adImages.map {presenter.uploadImagePromise(url: url!, image: $0)})
                .done { ([Any]) in
                    //und nu
                }.catch { error in
                    print(error)
            }
        } else {
            //something went wrong with inital creation of new article, stop progress and inform user
            SVProgressHUD.dismiss()
            
            let alertProblem = UIAlertController(title: "Problem", message: "", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "ok", style: .default) { (action) in
                print("was nun?")
            }
            alertProblem.addAction(ok)
            present(alertProblem, animated: true, completion: nil)
        }
    }
    
    
    func prepareForms() {
        //for space on left side
        let leftView = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftView.backgroundColor = .clear
        titleText.leftView = leftView
        titleText.leftViewMode = .always
        titleText.contentVerticalAlignment = .center
        titleText.placeholder = NSLocalizedString("new_article_titel", comment: "")
        
        //description
        descriptionText.placeholder = NSLocalizedString("new_article_description", comment: "")
        
        //price
        let leftViewPrice = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftViewPrice.backgroundColor = .clear
        price.leftView = leftViewPrice
        price.leftViewMode = .always
        price.contentVerticalAlignment = .center
        price.placeholder = NSLocalizedString("new_article_price", comment: "")
        
        //location
        let leftViewLoc = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftViewLoc.backgroundColor = .clear
        location.leftView = leftViewLoc
        location.leftViewMode = .always
        location.contentVerticalAlignment = .center
        location.placeholder = NSLocalizedString("new_article_location", comment: "")
    }
    
    func showUselessInfo() {
        let useLessAlert = UIAlertController(title: NSLocalizedString("new_article_useless_title", comment: ""), message: NSLocalizedString("new article_useless_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        useLessAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            self.saveArticleButton.isEnabled = true
            return
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(useLessAlert, animated: true, completion: nil)
    }
}


@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
