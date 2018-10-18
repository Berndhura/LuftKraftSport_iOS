//
//  ViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 16.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//  luftkraftsport

import UIKit
import Alamofire
import Firebase
import SDWebImage
import SwiftyJSON

class ViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ads: [Ad] = []
    
    var myBookmarks: [Int32] = []
    
    var searchController: UISearchController!
    
    var resultController = UITableViewController()
    
    var searchString: String?
    
    var isLoadingTableView = true
    
    var noMessagesLabel = UILabel()
    
    var callbackClosureMyArticles: (() -> Void)?
    
    var callbackClosureBookmarks: (() -> Void)?

    //refresh button in tabbar
    var refreshButton: UIBarButtonItem?
    
    //paging  page": 0, "size": 10, "pages": 4, "total": 31,
    let batchSize = 10
    var totalItems = 0  // ALL ads available!!
    var page = 0
    var size = 0
    var pages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO besser in appdelegate???
        SDWebImageDownloader.shared().setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
        
        checkLoginStatus()
        
        getMyBookmaks(type: "all")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        // -64 space for tabbar
        //self.tableView.contentInset = UIEdgeInsets(top: -64.0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.barTintColor = appMainColorBlue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tabBarController?.title = "Luftkraftsport"
    
        //refresh ads button in tabbar
        refreshButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(ViewController.refreshArticles))
        
        tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!], animated: true)
        
        tableView?.backgroundColor = UIColor.gray
        
        navigationController?.navigationBar.isTranslucent = true
        
        //connect searchBar
        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.placeholder = NSLocalizedString("main_search_title", comment: "")
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        adaptTitle()
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!], animated: true)
        
        //to get my article from homeViewController
        callbackClosureMyArticles?()
        callbackClosureBookmarks?()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
     
        //searchText = searchController.searchBar.text!
        //perform(#selector(test), with: nil, afterDelay: 2)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchString = searchBar.text!
        self.searchController.dismiss(animated: true, completion: nil)
        page = 0
        ads.removeAll()
        self.getMyBookmaks(type: "search")
    }
    
    func checkLoginStatus() {
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("google sign in")
        } else {
            print("google out")
        }
    }

    
    func refreshArticles() {
        
        //todo searchbar auch an anderen stellen "" setzen!!
        self.searchController.searchBar.text = ""
        ads.removeAll()
        page = 0
        getMyBookmaks(type: "all")
    }
    
    func showMyArticle() {
        page = 0
        ads.removeAll()
        getMyBookmaks(type: "my")
    }
    
    func showBookmarkedArticles() {
        page = 0
        ads.removeAll()
        getMyBookmaks(type: "bookmarked")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMyBookmaks(type: String) {
        
        if !Utils.isInternetAvailable() {
            
            let alert = UIAlertController(title: "No Internet Connection", message: "make sure your device is connected to the internet", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            tableView.backgroundColor = UIColor.white
            
            return
        }
        
        let userToken = Utils.getUserToken()
        
        if userToken != "" {
            
            let url = URL(string: "http://178.254.54.25:9876/api/V3/bookmarks/ids?token=\(userToken)")
            
            Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    self.myBookmarks.removeAll()
                    let res = String(describing: response.result.value)
                    if res.contains("Unauthorized") {
                        //nix
                    } else {
                        if let res = response.result.value {
                            self.myBookmarks = res as! [Int32]  //TODO crash hier wenn netzwerk verbunden aber kein service, wahrscheinlich wie bei ALLEN requests!!!
                        } else {
                            self.myBookmarks = []
                        }
                    }
                    self.fetchAds(type: type)
            }
        } else {
            self.myBookmarks.removeAll()
            self.fetchAds(type: type)
        }
    }
    
    func fetchAds(type: String) {
        
        print("fetching ads........................")
        
        //paging problem
        //var localAds: [Ad]  = []
        
        var url: URL
        
        if type == "all" {
            //all articles
            url = URL(string: "http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=\(page)&size=\(batchSize)")!
        } else if type == "search" {
            //search for article
            url = URL(string: "http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=0&size=30&description=\(searchString!)")!
            //TODO Paging einbauen
        } else if type == "bookmarked" {
            //bookmarks
            let token = Utils.getUserToken()
            //TODO check url -> distance
            url = URL(string: "http://178.254.54.25:9876/api/V3/bookmarks?lat=0.0&lng=0.0&distance=10000000&page=0&size=30&token=\(token)")!
        } else {
            //my articles
            let userToken = Utils.getUserToken()
            let urlString = Urls.getMyArticles + "?token=\(userToken)&page=0&size=30"  //TODO Paging einbauen
            url = URL(string: urlString)!
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    let json = JSON(response.result.value ?? "default")
                    
                    self.size = json["size"].int!
                    self.totalItems = json["total"].int!
                    self.pages = json["pages"].int!
                    
                    self.totalItems =  json["total"].int!
                    if self.totalItems == 0 && type == "search" {
                        self.showAlertForNoResults()
                        self.tableView.backgroundColor = UIColor.white
                    }
                    
                    for (_ , value) in json["ads"] {
                        
                        let title = value["title"].string
                        let descriptions = value["description"].string
                        let price = value["price"].int
                        let userId = value["userId"].string
                        let location = value["locationName"].string
                        let date = value["date"].double
                        let articleId = value["id"].int32
                        var urls = value["urls"].string
                        let lat =  value["location"]["coordinates"][0].double
                        let lng =  value["location"]["coordinates"][1].double
                        let views = value["views"].int
                        
                        if urls == nil {
                            urls = ""
                        }
                        
                        let ad = Ad(title: title!, desc: descriptions!, urls: urls!, price: price!, location: location ?? "", date: date!, userId: userId!, articleId: articleId!, lat: lat!, lng: lng!, views: views!)
                        
                        self.ads.append(ad)
                    }
                case .failure(let error):
                    //todo nice error handling -> inform user but do not hassle user
                    /*switch URLError.Code(rawValue: error.code) {
                    case .some(.notConnectedToInternet):
                        print("bix netz")
                    }*/
                    print(error)
                }
                //TODO paging problem
                //self.ads = localAds
                self.tableView.reloadData()
                self.adaptTitle()
        }
    }
    
    
    func adaptTitle() {
        self.tabBarController?.title = NSLocalizedString("ads", comment: "") + String(self.totalItems)
    }
    
    
    func getPictureUrl(str: String) -> String {
        let ind = str.split{$0 == ","}.map(String.init)
        if ind.count > 0 {
            return ind[0]
        } else {
            return "1"
        }
    }
    
    
    func showAlertForNoResults() {
        let alert = UIAlertController(title: NSLocalizedString("no_search_results", comment: ""), message: NSLocalizedString("no_search_results_details", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let detailViewController: DetailViewController = (segue.destination as? DetailViewController)!
            let cell: UITableViewCell? = sender as? UITableViewCell
            tabBarController?.title = ""
            if cell != nil {
                let indexPath: IndexPath? = self.tableView.indexPath(for: cell!)
                if indexPath != nil {
                    let ad: Ad = ads[indexPath!.row]
                    detailViewController.articleTitle = ad.title
                    detailViewController.pictureUrl = ad.urls//getPictureUrl(str: ad.urls)
                    detailViewController.desc = ad.desc
                    detailViewController.price = ad.price
                    detailViewController.location = ad.location
                    detailViewController.date = ad.date
                    detailViewController.userId = ad.userId
                    detailViewController.articleId = ad.articleId
                    detailViewController.lat = ad.lat
                    detailViewController.lng = ad.lng
                    detailViewController.myBookmarks = self.myBookmarks
                    detailViewController.views = ad.views
                }
            }
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()

extension ViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ads.count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("no_articles", comment: ""))
            self.searchController.searchBar.isHidden = true
        } else {
            self.tableView.restore()
            self.searchController.searchBar.isHidden = false
        }
        return ads.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //page": 0, "size": 10, "pages": 4, "total": 31,
        if (indexPath.row == ads.count - 1) { // last cell
            if (totalItems > ads.count && page <= pages) { // more items to fetch
                page += 1
                fetchAds(type: "all")  //TODO allgemein den typen hier durchschleifen all, serach, bookmarks
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: AdCell? = tableView.dequeueReusableCell(withIdentifier: "AdCell") as? AdCell
        
        cell?.mainViewController = self
        
        if cell == nil {
            cell = AdCell(style: .default, reuseIdentifier: "AdCell")
        }
        
        let currentAd: Ad = ads[indexPath.row]
        
        //articleId
        cell?.articleId = currentAd.articleId
        
        //description
        cell?.desc = currentAd.desc
        
        //sellerUserId
        cell?.userId = currentAd.userId
        
        //title
        cell?.title?.text = currentAd.title
        
        //views
        cell?.views?.text = "Views: " + String(describing: currentAd.views)
        
        //location
        cell?.location?.text = currentAd.location
        cell?.lat = currentAd.lat
        cell?.lng = currentAd.lng
        
        //date
        cell?.date?.text = Utils.getFormatedDate(date: currentAd.date)
        
        //price
        cell?.price?.text = String(currentAd.price) + " €"
        
        //pictureURLs
        cell?.pictureURL = currentAd.urls
        
        //bookmark
        if Utils.isLoggedIn() {
            if myBookmarks.contains(currentAd.articleId) {
                cell?.bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_white_36pt"), for: .normal)
            } else {
                cell?.bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_outline_white_36pt"), for: .normal)
            }
        }
        
        cell?.myBookmarks = self.myBookmarks
        
        //image
        let imageId = getPictureUrl(str: ads[indexPath.item].urls)
        
        let urlString = "http://178.254.54.25:9876/api/V3/pictures/\(imageId)"
        
        let url = URL(string: urlString)
        
        cell?.bild.sd_setImage(with: url!, placeholderImage: UIImage(named: "lks_logo_1024x1024"))

        //is my article
        if (currentAd.userId == Utils.getUserId()) {
            cell?.editButton.isHidden = false
            cell?.deleteButton.isHidden = false
        } else {
            cell?.editButton.isHidden = true
            cell?.deleteButton.isHidden = true
        }

        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight * 0.85
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 150.0
    }
}
