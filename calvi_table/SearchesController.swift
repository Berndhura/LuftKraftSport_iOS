//
//  SearchesController.swift
//  calvi_table
//
//  Created by bernd wichura on 09.11.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SearchesController: UIViewController, SearchCellDelegate {
 
    var searches: [Searches] = []
    
    var indexToDelete: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        prepareView()
        
        fetchSearches()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeSearchFromList), name: Notification.Name(Constants.searchDeleted), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    func deleteSearch(cell: SearchCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        self.indexToDelete = indexPath
    }
    
    
    func removeSearchFromList(_ notification: NSNotification) {
        searches.remove(at: indexToDelete!.row)
        self.tableView.deleteRows(at: [indexToDelete!], with: .fade)
    }
    
    
    func prepareView() {
        tableView.separatorStyle = .none
        tabBarController?.title = ""
    }
    
    
    func fetchSearches() {
        
        var localSearches: [Searches] = []
        
        let userToken = Utils.getUserToken()
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/searches?token=\(userToken)")
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    let jsonData = JSON(response.result.value ?? "default")
                    for (_ , value) in jsonData {
                        
                        let title = value["description"].string
                        let dist = value["distance"].int
                        let location = value["locationName"].string
                        let id = value["id"].int16
                        let maxPrice = value["priceTo"].int
                        let lat = value["lat"].double
                        let lng = value["lng"].double
                        
                        //TODO resultCount, priceFrom
                        let search = Searches(title: title!, distance: dist!, locationName: location!, id: id!, priceTo: maxPrice!, lat: lat!, lng: lng!)
                        
                        localSearches.append(search)
                    }
                case .failure(let error):
                    print(error)
                }
                self.searches = localSearches
                self.tableView.reloadData()
                
                self.navigationItem.title = NSLocalizedString("searches_title", comment: "") + String(self.searches.count)
        }
    }
}


extension SearchesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searches.count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("no_searches", comment: ""))
        } else {
            self.tableView.restore()
        }
        
        return searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: SearchCell? = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell
        
        if cell == nil {
            cell = SearchCell(style: .default, reuseIdentifier: "SearchCell")
        }
        
        cell?.delegate = self
        
        let search: Searches = searches[indexPath.row]
        
        //description
        cell?.desc?.text = NSLocalizedString("what", comment: "") + search.title
        
        //location
        cell?.location.text = NSLocalizedString("where", comment: "") + search.locationName
        
        //distance
        let distance = (search.distance == Constants.unlimitedRange) ? NSLocalizedString("unlimited", comment: "") : String(describing: search.distance) + " km"
        cell?.distance.text = NSLocalizedString("radius", comment: "") + distance
        
        //id
        cell?.searchId = search.id
        
        //max price
        let maxPrice = NSLocalizedString("max_price", comment: "") + ((search.priceTo == Constants.maxPrice) ? NSLocalizedString("price_dnm", comment: "") :  (String(describing: search.priceTo)) + " €")
        cell?.price?.text =  maxPrice
        
        return cell!
    }
    
    func getFormatedDate(date: Double) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMdd")
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let date = Date(timeIntervalSince1970: (date / 1000.0))
        return dateFormatter.string(from: date)
    }
}


extension SearchesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        return screenHeight / 5.0
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let search: Searches = searches[indexPath.row]
        var payload:[String: Searches] = [:]
        payload["search"] = search
        
        NotificationCenter.default.post(name: Notification.Name(Constants.searchFor), object: nil, userInfo: payload)
        /*
         TODO: pop VC in viewController to avoid crash
         self.navigationController?.popViewControllerWithHandler(completion: {
            NotificationCenter.default.post(name: Notification.Name(Constants.searchFor), object: nil, userInfo: payload)
        })*/
    }
}

extension UINavigationController {
    //Same function as "popViewController", but allow us to know when this function ends
    func popViewControllerWithHandler(completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }
    
    
    func pushViewController(viewController: UIViewController, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}

