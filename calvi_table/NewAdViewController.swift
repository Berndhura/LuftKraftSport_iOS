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
            updateArticle()
        } else {
            saveArticleButton.isEnabled = false
            getLatLng(address: location.text!)
        }
    }
    
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
        
        titleText.returnKeyType = UIReturnKeyType.next
        decriptionText.returnKeyType = UIReturnKeyType.next
        price.returnKeyType = UIReturnKeyType.next
        location.returnKeyType = UIReturnKeyType.send
        
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
            decriptionText.becomeFirstResponder()
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
            "coordinates": [47.0, 13.5]]
        
        
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
        
        var i = 0
        
        //TODO nicht alle werden hochgeladen leider
        for img in adImages {
            
            let imageData = UIImageJPEGRepresentation(img, 0.5)!
            
            let parameters = [
                "file_name": "swift_file.jpeg"
            ]
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData, withName: "file", fileName: "file\(i).jpeg", mimeType: "image/jpeg")
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: url!)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (Progress) in
                    //print("Upload Progress: \(Progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                    
                        i += 1
                        print("------------------------------")
                        print("upload image: \(i) ")
                        print(response)
                        
                        if i == self.adImages.count {
                            print("returning")
                            //return to main list
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = tabBarController
                        }
                        
                    }
                    
                case .failure(let encodingError):
                    //self.delegate?.showFailAlert()
                    print(encodingError)
                }
            }
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
 
        self.titleText.placeholder = "Was verkaufst du..."
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
