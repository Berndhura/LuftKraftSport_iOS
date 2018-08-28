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
    
    //to hide keyboard when tapped
    var hideTap: UITapGestureRecognizer!
    
    var adButtonViews = [UIButton]()
    
    var adImages = [UIImage]()
    
    var changedImages = [Bool]()
    
    var currentImageView: UIImageView?
    
    var currentImageNumber: Int = 0
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        for _ in 0...4 {
            changedImages.append(false)
        }

        presenter.attachView(self)
        
        presenter.init_data(pictureUrl: pictureUrl, isEditMode: isEditMode)
        
        decriptionText.delegate = self
        titleText.delegate = self
        price.delegate = self
        location.delegate = self
        
        
        titleText.returnKeyType = UIReturnKeyType.next
        decriptionText.returnKeyType = UIReturnKeyType.next
        price.returnKeyType = UIReturnKeyType.next
        location.returnKeyType = UIReturnKeyType.send
        
        location.addTarget(self, action: #selector(NewAdViewController.locationDidChange(_:)), for: UIControlEvents.editingChanged)

        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
        
        //declare hide keyboard tap
        hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //add observer for location: only get new location name in case it is changed
        //does not work: every new letter observer hits -> better get lat/lng before send request
        //NotificationCenter.default.addObserver(self, selector: #selector(self.getLatLngFromLocationName), name: .UITextFieldTextDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func locationDidChange(_ textField: UITextField) {
        isLocationChanged = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshTabBar()
    }
    
    //hide keyboard if tapped
    func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        print("hide Keyboard")
    }
    
    func keyboardWillChange(notification: NSNotification) {
        //get keyboard size for device
        let keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)!
        
        if (notification.name == .UIKeyboardWillShow || notification.name == .UIKeyboardWillChangeFrame) {
                print("showKeyboard")
            view.frame.origin.y = -keyboard.height
        } else {
            print("hideKeyboard")
            view.frame.origin.y = 0
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
        
        let gapSize: CGFloat = 15
        
        for i in 0..<5 {
            
            let imageButton = UIButton()
            imageButton.setBackgroundImage(UIImage(named: "image_placeholder"), for: .normal)
            imageButton.tag = i
            imageButton.addTarget(self, action: #selector(imageTapped), for: .allTouchEvents)
            imageButton.contentMode = .scaleToFill
            imageButton.isUserInteractionEnabled = true
            imageButton.layer.cornerRadius = 20
            imageButton.layer.masksToBounds = true
            
            let xPosition = self.imgScrollView.frame.height * CGFloat(i) + (gapSize * CGFloat(i + 1))
            imageButton.frame = CGRect(x: xPosition  , y: 0, width: imgScrollView.frame.height, height: imgScrollView.frame.height)
            
            imgScrollView.contentSize.width = imgScrollView.frame.height * CGFloat(i + 1) + (gapSize * CGFloat(i + 1))
            imgScrollView.addSubview(imageButton)
            adButtonViews.append(imageButton)
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            adButtonViews[currentImageNumber].setImage(chosenImage, for: .normal)
            adImages.append(chosenImage)
        }
        picker.dismiss(animated: true, completion: nil)
        
        if isEditMode {
            let urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
            
            print("GERO: " + urlList[currentImageNumber])
            
            //store image into image list
            adImages.append((info[UIImagePickerControllerOriginalImage] as? UIImage)!)
            
            changedImages[currentImageNumber] = true
            
            
            //welche bilder werden gelöscht .-> alte bilder in eine liste dann löschen .. dann update
            
            //delete  image ist raus: alle bilder vom picker werden in adImages abgespeichert und erst zum schluss hochgeladen "Abspeichern"
            //presenter.deleteImage(articleId: articleId, imageId: Int(urlList[currentImageNumber])!, info: info)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField === titleText) {
            //TODO wieder auf weiter umstellen oder bei return keyboard verschwinden lassen?
            self.view.endEditing(true)
            //decriptionText.becomeFirstResponder()
        } else if (textField === decriptionText) {
            price.resignFirstResponder()
        } else if (textField === price) {
            location.becomeFirstResponder()
        }
        
        if (textField.returnKeyType == UIReturnKeyType.send) {
            // tab forward logic here
            print("senden")
        }
        /*- jo das passt ausser next in beschreibung weil kein kein textfiled sondern textview!!
        
         - 3 bilder auswählbar mach_vm_read_entry
         - bearbeiten der anzeige, nicht neu abspeichern
         - alles allignen abstand bilder von top
         - schriftgrösse?
         standort eingabe richtig so? was wenn quatscheingegeben?
         - */
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            price.resignFirstResponder()
            print("maul2")
        }
        return true;
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
        
        let gapSize: CGFloat = 5
        
        for i in 0..<urlList.count {
            
            let imageButton = UIButton()
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(urlList[i])")
            imageButton.sd_setImage(with: url!, for: .normal, completed: nil)
            imageButton.tag = i
            imageButton.addTarget(self, action: #selector(imageTapped), for: .allTouchEvents)
            imageButton.contentMode = .scaleToFill
            imageButton.isUserInteractionEnabled = true
            imageButton.contentMode = .scaleAspectFill

            let xPosition = self.imgScrollView.frame.height * CGFloat(i) + (gapSize * CGFloat(i + 1))
            imageButton.frame = CGRect(x: xPosition  , y: 0, width: imgScrollView.frame.height, height: imgScrollView.frame.height)
            
            imgScrollView.contentSize.width = imgScrollView.frame.height * CGFloat(i + 1) + (gapSize * CGFloat(i + 1))
            imgScrollView.addSubview(imageButton)
            adButtonViews.append(imageButton)
        }
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
        
        print("picture URLS   OLD--------------------------------")
        print(self.pictureUrl)
        
        self.deleteImageFromListAndServer()
        print("picture URLS   NEW--------------------------------")
        print(self.pictureUrl)
        
        let newPictureUrls = self.pictureUrl
        
        self.uploadNewImagesToAd()
        
        var params = [
            "id": self.articleId,
            "price": self.price.text! as Any,
            "title": self.titleText.text! as Any,
            //no image changes/edits/delete -> only use old ones
            //if URLs string is empty do not set URLS -> URLs are NULL
            "urls" : ((newPictureUrls != "") ? newPictureUrls as Any : nil),   //wenn geändert, die ides von den BEREITS gelöschten müssen hier raus!! und der rest wird mitgegben
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
    
    
    func uploadNewImagesToAd() {
        let userToken = Utils.getUserToken()
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
        
        when(fulfilled: adImages.map {presenter.uploadImagePromise(url: url!, image: $0)})
            .done { ([Any]) in
                //und nu
        }
    }
    
    func deleteImageFromListAndServer() {
        for i in 0...4 {
            if changedImages[i] {
                //image changed, delete old once
                let id = Int(presenter.getImageId(forPosition: i))
                let newPictureUrl = presenter.deleteImageIdFromList(imageId: id!)
                //new imageUrl String
                self.pictureUrl = newPictureUrl
                presenter.deleteImage(articleId: articleId, imageId: id!)
            }
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
