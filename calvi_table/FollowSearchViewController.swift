//
//  FollowSearchViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 23.12.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import Alamofire
import DownPicker
import CoreLocation


class FollowSearchViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextInput: UITextField!
    
    @IBOutlet weak var priceInput: UITextField!
    
    @IBOutlet weak var priceLable: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var mainInfoLable: UILabel!
    
    @IBOutlet weak var radiusLable: UILabel!
    
    @IBOutlet weak var radiusInput: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var serachTextLable: UILabel!
    
    @IBOutlet weak var locationInput: UITextField!
    
    @IBOutlet weak var locLable: UILabel!
    
    var searchText: String?
    
    var radiusPicker: DownPicker!
    
    var locationManager: CLLocationManager!
    
    var locValue: CLLocationCoordinate2D?
    
    @IBAction func locationClicked(_ sender: Any) {
        print("open da map")
        //TODO open map and change location
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followSearchPressed(_ sender: Any) {
    
        let userToken = Utils.getUserToken()
        
        let price = getPrice()
        
        let distance = getDistance()
        
        let lat = getLat()
        
        let lng = getLng()
        
        if validateInput() {
            
            let text = getSearchText()
        
            let url = URL(string: "http://178.254.54.25:9876/api/V3/searches/new?description=\(text)&priceFrom=0&priceTo=\(price)&lat=\(lat)&lng=\(lng)&distance=\(distance)&token=\(userToken)")
            
            Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    print(response)
                    let alert = UIAlertController(title: NSLocalizedString("follow_search_saved", comment: ""), message: nil, preferredStyle: .actionSheet)
                    self.present(alert, animated: true, completion: nil)
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        
        initElements()
        
        initLocationManager()
        
        getLocationName()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func initLocationManager() {
        
        locationManager = CLLocationManager()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location?.coordinate
        print("lat lng: \(locValue!.latitude) \(locValue!.longitude)")
        Utils.setLastLocation(lat: locValue!.latitude, lng: locValue!.longitude)
    }
    
    fileprivate func getNameFromLatLng(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                let location = pm.locality
                self.locationInput.text = location
                
                Utils.setLastLocationName(locationName: location)
            }
        }
    }
    
    func getLocationName() {
        
        if let loc = locValue {
            let lat = loc.latitude
            let lng = loc.longitude
            
            let location = CLLocation(latitude: lat, longitude: lng)
            getNameFromLatLng(location)
        } else {
            let lastLocation = Utils.getLastLocation()
            let location = CLLocation(latitude: lastLocation.lat ?? Constants.defaultLatitude, longitude: lastLocation.lng ?? Constants.defaultLongitude)
            getNameFromLatLng(location)
        }
    }
    
    
    func getLat() -> Double {
        if let lat = locValue {
            return lat.latitude
        } else {
            //TODO gps aus ! was zurück geben?
            return 0.0
        }
    }
    
    
    func getLng() -> Double {
        if let lng = locValue {
            return lng.longitude
        } else {
            //TODO gps aus ! was zurück geben?
            return 1.1
        }
    }
    
    func validateInput() -> Bool {
        
        if let text = searchTextInput.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if (text.isEmpty || trimmedText == "")  {
                let alert = UIAlertController(title: NSLocalizedString("empty_search_text_hint", comment: ""), message: nil, preferredStyle: .actionSheet)
                self.present(alert, animated: true, completion: nil)
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
            } else {
                return true
            }
        } else {
            return false
        }
        return false
    }
    
    
    func getSearchText() -> String {
        return searchTextInput.text!
    }
    
    
    func getPrice() -> Int {
        
        if let maximum = Int(priceInput.text!) {
            if priceInput.text!.isEmpty {
                return Constants.maxPrice
            } else {
                return maximum
            }
        } else {
            if priceInput.text! == NSLocalizedString("price_dnm", comment: "") {
                return Constants.maxPrice
            } 
        }
        
        return Constants.maxPrice
    }
    
    
    func getDistance() -> Int {
        
        if let radius = Int(radiusPicker.getTextField()?.text ?? NSLocalizedString("unlimited", comment: "")) {
            return radius
        } else {
            return Constants.unlimitedRange
        }
    }
    
    func initElements() {
        
        radiusLable.text = NSLocalizedString("radius", comment: "")
        
        let unlimitedRange = NSLocalizedString("unlimited", comment: "")
        let radius = ["10", "20", "50", "100", "200", unlimitedRange]
        radiusPicker = DownPicker(textField: radiusInput, withData: radius)
        radiusPicker.getTextField()?.text = unlimitedRange
        
        priceLable.text = NSLocalizedString("price", comment: "")
        priceInput.text = NSLocalizedString("price_dnm", comment: "")
        
        saveButton.backgroundColor = appMainColorBlue
        saveButton.setTitle(NSLocalizedString("followSearch", comment: ""), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        
        backButton.backgroundColor = appMainColorBlue
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle(NSLocalizedString("abort", comment: ""), for: .normal)
        
        mainInfoLable.text = NSLocalizedString("searches_explain", comment: "")
        
        locLable.text = NSLocalizedString("location", comment: "")
        locationInput.isUserInteractionEnabled = false
        locationInput.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "location")
        imageView.image = image
        locationInput.rightView = imageView
        
        serachTextLable.text = NSLocalizedString("search_text_lable", comment: "")
        
        searchTextInput.text = searchText
    }
}
