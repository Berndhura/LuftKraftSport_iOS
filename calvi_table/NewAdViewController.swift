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
import SDWebImage
import RxSwift
import SVProgressHUD

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

    
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var decriptionText: UITextViewFixed!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var saveArticleButton: UIButton!
    
    @IBAction func saveNewAd(_ sender: Any) {
        if isEditMode {
            saveArticleButton.isEnabled = false
            SVProgressHUD.show(withStatus: "Anzeige wird geändert...")
            updateArticle()
        } else {
            saveArticleButton.isEnabled = false
            getLatLng(address: location.text!)
            SVProgressHUD.show(withStatus: "Neue Anzeige wird erstellt...")
        }
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func abortEditing(_ sender: Any) {
        //TODO funzt nur wenn die Tab Bar Items auch da sind! Dann aber sehr gut!!! selbst die Daten sind noch da, nach wechsel back back
        //TODO falls die nicht da sind, wie beim editieren vom Ad ??? was dann???
        self.tabBarController?.selectedIndex = 0
    }
    
    //to hide keyboard when tapped
    var hideTap: UITapGestureRecognizer!
    
    var adButtonViews = [UIButton]()
    
    var adImages = [UIImage]()
    
    var currentImageView: UIImageView?
    
    var currentImageNumber: Int = 0
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        decriptionText.delegate = self
        titleText.delegate = self
        price.delegate = self
        location.delegate = self
        
        //TODO next hier wieder benutzen
        //titleText.returnKeyType = UIReturnKeyType.next
        decriptionText.returnKeyType = UIReturnKeyType.next
        price.returnKeyType = UIReturnKeyType.next
        location.returnKeyType = UIReturnKeyType.send
        
        if isLoggedIn() {
        
            if isEditMode {
                saveArticleButton.setTitle("Änderung speichern", for: .normal)
                //addGestureOnImages()
                editArticle()
                
            } else {
                setupImagesPlaceholder()
                //addGestureOnImages()
                prepareForms()
            }
        }
        
        //TODO does not work at all
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.backTo))
        backSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(backSwipe)
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
        
        //declare hide keyboard tap
        hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
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
    
    func backTo(gesture: UISwipeGestureRecognizer) {
        //TODO funzt noch nicht
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func isLoggedIn() -> Bool {
        
        if Utils.getUserToken() == "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.pushViewController(newViewController, animated: true)
            return false
        } else {
            //user in
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        refreshTabBar()
    }
    
    func refreshTabBar() {
        
        self.tabBarController?.title = "Erstelle eine Anzeige"

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
         - scollbar machen sonst ist bei eingabe das textfeld nict zu sehen
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
        
        titleText.text = titleFromAd
        decriptionText.text = descFromAd
        price.text = String(describing: priceFromAd)
        location.text = locationFromAd
        
        let urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
        
        requestAllAdPictures(urlList: urlList)
    }
    
    func requestAllAdPictures(urlList: [String]) {
        
        for i in 0..<urlList.count {
            
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(urlList[i])")
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    self.adImages.append(UIImage(data: data!)!)
                    
                    // async request, possible that last request comes first -> only show pictures
                    // when all pics are downloaded   
                    // TODO better request each image during swipeing gesture
                    if (self.adImages.count == urlList.count) {
                        self.showPictures()
                    }
                })
                }.resume()
        }
    }

    func showPictures() {
        
        let gapSize: CGFloat = 5
        
        for i in 0..<adImages.count {
            
            let imageButton = UIButton()
            imageButton.setBackgroundImage(adImages[i], for: .normal)
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
    
    
    func updateArticle() {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        var params = [
            "id": articleId,
            "price": price.text! as Any,
            "title": titleText.text! as Any,
            "description": decriptionText.text! as Any
            ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [47.0, 13.5]]  //TODO location -> lat,lng
        
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarController
        }
        
        /* update, der bestehenden ad,
         dazu bilder  updaten
         flag welches bild angefasst wurdd
         */
    }
    
    func createNewAd(coordinate: CLLocationCoordinate2D) {
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        let price = "69"
        
        var params = [
            "price": String(price)! as Any,
            "title": titleText.text! as Any,
            "description": decriptionText.text,
            "date": "12312323"
        ] as [String : Any]
        
        params["location"] = [
            "type": "Point",
            "coordinates": [coordinate.latitude, coordinate.longitude]]
        
        //print(params)

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
        let articleId = dict["id"]!
        
        print("neue articleID: " + String(describing: articleId))
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
        
        print(adImages.count)
        
        for img in self.adImages {
            
            uploadImage(url: url!, image: img)
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
    func uploadImage(url: URL, image: UIImage) {
        
        print("UPLOADING...........")
        
        let parameters = ["file": "swift_file.jpeg"]
        
        let imageData = UIImageJPEGRepresentation(image, 0.1)!
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(imageData, withName: "file", fileName: "file\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    //print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    print(response)
                    
                    /*if i == self.adImages.count {
                     print("returning")
                     //return to main list
                     */
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController
                    
                    SVProgressHUD.dismiss()
                    
                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print(encodingError)
            }
        }
    }
    
    func wrapper() -> Observable<String> {
        
        return Observable.create { observer in
            
            let URL = try! URLRequest(url: "http://example.com", method: .post)
            
            Alamofire.upload(
                multipartFormData: { formData in
                    // multiaprt
            },
                with: URL,
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            // convert response in something of SomeResponseType
                            // ...
                            observer.onNext("String")
                            observer.onCompleted()
                        }
                    case .failure(let encodingError):
                        observer.onError(encodingError)
                    }
            })
            
            return Disposables.create()
        }
    }

    func getLatLng(address: String) {
        
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error as Any)
                return
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                self.createNewAd(coordinate: coordinate!)
            }
        })
    }
    
    func prepareForms() {
 
        self.titleText.placeholder = NSLocalizedString("title_placeholder", comment: "Was soll hier hin")
        self.decriptionText.placeholder = "Beschreibe dein Angebot..."
        self.price.placeholder = "Preis..."
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
