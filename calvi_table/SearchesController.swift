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
                        
                        //TODO resultCount, priceFrom, lng, priceTo, lat
                        let search = Searches(title: title!, distance: dist!, locationName: location!, id: id!)
                        
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
        cell?.desc?.text = search.title
        
        //location
        cell?.location.text = search.locationName
        
        //distance
        cell?.distance.text = String(describing: search.distance)
        
        //id
        cell?.searchId = search.id
        
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
        
        return screenHeight / 7.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 100.0
    }
}

