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

class NewAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

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
    
    let gapSize: CGFloat = 5
    
    fileprivate let presenter = ArticlePresenter()

    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var decriptionText: UITextViewFixed!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var saveArticleButton: UIButton!
    
    @IBAction func saveNewAd(_ sender: Any) {
        if isEditMode {
            saveArticleButton.isEnabled = false
            SVProgressHUD.show(withStatus: NSLocalizedString("new_article_change_button", comment: ""))
            updateArticle()
        } else {
            saveArticleButton.isEnabled = false
            presenter.getLatLng(address: location.text!)
            SVProgressHUD.show(withStatus: NSLocalizedString("new_artivcle_create_ad", comment: ""))
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

        presenter.attachView(self)
        
        presenter.init_data(pictureUrl: pictureUrl, isEditMode: isEditMode)
        
        decriptionText.delegate = self
        titleText.delegate = self
        price.delegate = self
        location.delegate = self
        
        initImageIdDict()
        
        location.returnKeyType = UIReturnKeyType.send
        
        location.addTarget(self, action: #selector(NewAdViewController.locationDidChange(_:)), for: UIControlEvents.editingChanged)
        titleText.addTarget(self, action: #selector(NewAdViewController.titleDidChange(_:)), for: .editingDidEnd)
        
        if isLoggedIn() {
            if isEditMode {
                saveArticleButton.setTitle(NSLocalizedString("new_article_save_changes_button", comment: ""), for: .normal)
                //addGestureOnImages()
                print("GERO: PictureURL:" + pictureUrl)
                editArticle()
            } else {
                saveArticleButton.setTitle(NSLocalizedString("new_article_save_button", comment: ""), for: .normal)
                setupImagesPlaceholder()
                //addGestureOnImages()
                prepareForms()
            }
        } else {
            openLogin()
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        refreshTabBar()
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
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(newViewController, animated: true)
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
            print("senden")
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
        decriptionText.text = descFromAd
        price.text = String(describing: priceFromAd)
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
            imagePlaceholder(imageNumber: urlList.count)   //TODO urllist.count muss weiter hoch gezählt werden
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
            "description": self.decriptionText.text! as Any
            ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [lat, lng]]
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                
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
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        let price = self.price.text!
        
        var params = [
            "price": String(price)! as Any,
            "title": titleText.text! as Any,
            "description": decriptionText.text
            ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [coordinate.latitude, coordinate.longitude]]
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                self.uploadImagesForNewAd(response: response)
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
        
        decriptionText.placeholder = NSLocalizedString("new_article_description", comment: "")
    
        let leftViewPrice = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftViewPrice.backgroundColor = .clear
        price.leftView = leftViewPrice
        price.leftViewMode = .always
        price.contentVerticalAlignment = .center
        price.placeholder = NSLocalizedString("new_article_price", comment: "")
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
