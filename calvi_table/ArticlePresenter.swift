//
//  ArticlePresenter.swift
//  calvi_table
//
//  Created by bernd wichura on 09.08.18. in Geraldton WA
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import CoreLocation
import PromiseKit


class ArticlePresenter {

    weak fileprivate var userView : NewAdViewController?
    fileprivate var pictureUrl: String = ""
    fileprivate var isEditMode: Bool = false
    
    func attachView(_ view: NewAdViewController){
        userView = view
    }
    
    func init_data(pictureUrl: String, isEditMode: Bool) {
        self.pictureUrl = pictureUrl
        self.isEditMode = isEditMode
    }
    
    func deleteImage(articleId: Int32, imageId: Int, info: [String: Any]) {
        let userToken = Utils.getUserToken()
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/\(imageId)/deletePicture?token=\(userToken)")
        Alamofire.request(url!, method: .delete, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                debugPrint(response)
                
                //first delete image from local image list
                self.deleteImageIdFromList(imageId: imageId)
                //then upload new image to server
                let image = info[UIImagePickerControllerOriginalImage] as? UIImage
                let userToken = Utils.getUserToken()
                let url = URL(string: "http://178.254.54.25:9876/api/V3/articles/\(articleId)/addPicture?token=\(userToken)")
                
                //TODO richtig hier -> upload kommt auch in presenter
                //self.uploadImage(url: url!, image: image!)
        }
    }
    
    func deleteImageIdFromList(imageId: Int) {
        
        var urlList: [String] = Utils.getAllPictureUrls(str: pictureUrl)
        var pos = 0
        for url in urlList {
            if url == String(imageId) {
                urlList.remove(at: pos)
                print("id removed!")
                print(urlList)
            }
            pos = pos + 1
        }
        
        self.pictureUrl.removeAll()
        pos = 0
        for url in urlList {
            if (pos == 0) {
                self.pictureUrl += url
            } else {
                self.pictureUrl += "," + url
            }
            pos += 1
            print("pictureURL: ")
        }
        
        print("GERO: bearbeitete imige urls: " + self.pictureUrl)
    }
    
   
    //PromiseKit upload for image
    func uploadImagePromise(url: URL, image: UIImage) -> Promise<Any> {
        
        Thread.sleep(forTimeInterval: 1)
        
        // shrink image for upload to server
        let parameters = ["file": "swift_file.jpeg"]
        let imageData = UIImageJPEGRepresentation(image, 0.1)!
        print("im uploadPromise!!!")
        print(imageData.count)
        return Promise { seal in
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData, withName: "file", fileName: "file\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
            }, to: url) { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload
                        .validate()
                        .responseJSON { response in
                            //deactivete Progress
                            print("fertig upload")
                            SVProgressHUD.dismiss()
                    }
                case .failure(let error):
                    print(error)
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
                
                self.userView?.createNewAd(coordinate: coordinate!)
            }
        })
    }
}
