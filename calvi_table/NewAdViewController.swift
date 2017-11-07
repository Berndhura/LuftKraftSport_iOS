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

   
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var imageTwo: UIImageView!
    
    @IBOutlet weak var imageThree: UIImageView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var decriptionText: UITextView!
    
    @IBOutlet weak var price: UITextField!
   
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var saveArticleButton: UIButton!
    
    @IBAction func saveNewAd(_ sender: Any) {
        
        if isEditMode {
            updateArticle()
        } else {
            getLatLng(address: location.text!)
        }
    }
    
    var currentImageView: UIImageView?
    
    //TODO scheiß weil was wenn mehrmals das selbe bild geändert wird?
    var imageSize: Int = 0
    
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
        
        
        //self.decriptionText.returnKeyType = UIReturnKeyType.done
        
        if isEditMode {
            
            saveArticleButton.setTitle("Änderung speichern", for: .normal)
            addGestureOnImages()
            editArticle()
            
        } else {
        
            addGestureOnImages()
            prepareForms()
        }
    }
    
    func addGestureOnImages() {
        
        let tapGestureImgOne = UITapGestureRecognizer(target: self, action: #selector(imageTapped1))
        let tapGestureImgTwo = UITapGestureRecognizer(target: self, action: #selector(imageTapped2))
        let tapGestureImgThree = UITapGestureRecognizer(target: self, action: #selector(imageTapped3))
         
            
        image.addGestureRecognizer(tapGestureImgOne)
        image.isUserInteractionEnabled = true
        image.layer.setValue(1, forKey: "imageNumber")

        imageTwo.addGestureRecognizer(tapGestureImgTwo)
        imageTwo.isUserInteractionEnabled = true
        imageTwo.layer.setValue(2, forKey: "imageNumber")

        imageThree.addGestureRecognizer(tapGestureImgThree)
        imageThree.isUserInteractionEnabled = true
        imageThree.layer.setValue(3, forKey: "imageNumber")

    }
    
    func imageTapped1() {
        
        imageSize  += 1
        
        let picker = UIImagePickerController()
        
        self.currentImageView = image
        
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imageTapped2() {
        
        imageSize  += 1
        
        let picker = UIImagePickerController()
        
        self.currentImageView = imageTwo

        
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    
    func imageTapped3() {
        
        imageSize  += 1
        
        let picker = UIImagePickerController()
        
        self.currentImageView = imageThree

        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.currentImageView?.image = chosenImage
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
        
        self.titleText.text = titleFromAd
        self.decriptionText.text = descFromAd
        self.price.text = String(describing: priceFromAd)
    
        
        //images
        //print(pictureUrl)
        //self.image.sd_setImage(with: URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(pictureUrl)"))
        
        let urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
        
        getThemAll(urlList: urlList)
        
        let firstId = Utils.getPictureUrl(str: pictureUrl)
        
        //iteriere durch urllist ..... zeige images
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(firstId)")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                //let imageToCache = UIImage(data:data!)
                //if imageToCache != nil {
                //    imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                self.image.image = UIImage(data: data!)
            })
            }.resume()

    }
    
    func getThemAll(urlList: [String]) {
        
        var imageArry = [UIImage]()
        
        for i in 0..<urlList.count {
            
            let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(urlList[i])")
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: {

                    imageArry.append(UIImage(data: data!)!)
                })
            }.resume()
        }
        print("sd") //nix drinne weil asyncron :-(
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
        
        print(params)

        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                self.uploadImagesForNewAd(response: response)
        }
    }
    
    func uploadImagesForNewAd(response: DataResponse<Any>) {
        
        imageSize  = 0
     
        //print(response)
        
        //get new ID from response
        var dict: NSDictionary!
        dict = response.result.value as! NSDictionary
        let articleId = dict["id"]!
        
        print("neue articleID: " + String(describing: articleId))
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
        
        let imageData = UIImageJPEGRepresentation(self.image.image!, 0.5)!
        
        let parameters = [
            "file_name": "swift_file.jpeg"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "file", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url!)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                   // print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //self.delegate?.showSuccessAlert()
                   // print(response.request)  // original URL request
                   // print(response.response) // URL response
                    //print(response.data)     // server data
                   // print(response.result)   // result of response serialization
                    //                        self.showSuccesAlert()
                    //self.removeImage("frame", fileExtension: "txt")
                    //if let JSON = response.result.value {
                    //    print("JSON: \(JSON)")
                    //}
                    
                    //return to main list
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = sb.instantiateViewController(withIdentifier: "NavBarController") as! UINavigationController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = tabBarController

                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print(encodingError)
            }
            
        }
        
        //back to main..
        //let chatController: ChatViewController = (segue.destination as? ChatViewController)!
        
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
        //self.decriptionText.placeholder = "maul"
    }
}
