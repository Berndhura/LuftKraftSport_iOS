//
//  NewAdControllerViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 02.10.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//

import UIKit
import Alamofire

class NewAdViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBOutlet weak var decriptionText: UITextView!
    
    @IBAction func saveNewAd(_ sender: Any) {
        createNewAd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        
        // add it to the image view;
        image.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        image.isUserInteractionEnabled = true
        
        prepareForms()

    }
    
    func createNewAd() {
        /*
     @POST("articles")
     Observable<RowItem> saveNewAd(@Query("token") String userToken,
     @Body RowItem item);
     */
        let userToken = getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?token=\(userToken)")
        
        let price = "69"
        
        let params = [
            "price": String(price),
            "title": titleText.text,
            "description": decriptionText.text
        ]

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
        
        /*
         @Multipart
         @POST("articles/{articleId}/addPicture")
         Observable<String> uploadPicture(@Path("articleId") Long articleId,
         @Query("token") String userToken,
         @Part MultipartBody.Part file);
 */
        let userToken = getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
        
        let imageData: NSData = UIImagePNGRepresentation(self.image.image!)! as NSData
        
        let parameters = [
            "file_name": "swift_file.jpeg"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(self.image.image!, 0.5)!, withName: "file", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url!)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //self.delegate?.showSuccessAlert()
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    //                        self.showSuccesAlert()
                    //self.removeImage("frame", fileExtension: "txt")
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print(encodingError)
            }
            
        }
    }
    
    func getUserToken() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        let userToken: String? = defaults.string(forKey: "userToken")
        return userToken!
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