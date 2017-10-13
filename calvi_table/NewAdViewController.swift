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

class NewAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEditMode {
            
            saveArticleButton.setTitle("Änderung speichern", for: .normal)
            editArticle()
            
        } else {
        
            let tapGestureImgOne = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            
            image.addGestureRecognizer(tapGestureImgOne)
            //imageTwo.addGestureRecognizer(tapGestureImgTwo)
            // make sure imageView can be interacted with by user
            image.isUserInteractionEnabled = true
            image.layer.setValue(1, forKey: "imageNumber")
            imageTwo.isUserInteractionEnabled = true
            
            prepareForms()
        }
    }

    func editArticle() {
        
        self.titleText.text = titleFromAd
        self.decriptionText.text = descFromAd
        //self.price.text = 23.0
        
        //location
        
        // pic?
    }
    
    func updateArticle() {
        
        
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
     
        print(response)
        
        //get new ID from response
        var dict: NSDictionary!
        dict = response.result.value as! NSDictionary
        let articleId = dict["id"]!
        
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
    
    func imageTapped() {

        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
        image.image = chosenImage
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
