//
//  FollowSearchViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 23.12.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import Alamofire


class FollowSearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextInput: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var mainInfoLable: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var serachTextLable: UILabel!
    var searchText: String?
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followSearchPressed(_ sender: Any) {
    
        let userToken = Utils.getUserToken()
        let url = URL(string: "http://178.254.54.25:9876/api/V3/searches/new?description=\(searchText!)&priceFrom=0&priceTo=1000000&lat=0&lng=0&distance=1000&token=\(userToken)")
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)
                let alert = UIAlertController(title: NSLocalizedString("follow_search_saved", comment: ""), message: nil, preferredStyle: .actionSheet)
                self.present(alert, animated: true, completion: nil)
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        
        initElements()
        
        view.superview?.frame =  CGRect(x: 0, y: 0, width: 200, height: 200)
    }
    
    func initElements() {
        saveButton.backgroundColor = appMainColorBlue
        saveButton.setTitle(NSLocalizedString("followSearch", comment: ""), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        
        backButton.backgroundColor = appMainColorBlue
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle(NSLocalizedString("abort", comment: ""), for: .normal)
        
        mainInfoLable.text = NSLocalizedString("searches_explain", comment: "")
        
        serachTextLable.text = NSLocalizedString("search_text_lable", comment: "")
        
        searchTextInput.text = searchText
    }
}
