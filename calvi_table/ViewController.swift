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

class ViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ads: [Ad] = []
    
    var myBookmarks: [Int32] = []
    
    var searchController: UISearchController!
    var resultController = UITableViewController()
    
    var searchString: String?
    
    //refresh button in tabbar
    var refreshButton: UIBarButtonItem?
    var loginButton: UIBarButtonItem?
    var homeButton: UIBarButtonItem?
    
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
        
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 10/250, green: 100/250, blue: 200/250, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tabBarController?.title = "Luftkraftsport"
    
        //refresh ads button in tabbar
        refreshButton = UIBarButtonItem.init(image: UIImage(named: "loading"), style: .plain, target: self, action: #selector(ViewController.refreshArticles))
        
        //login button in tabbar
        loginButton = UIBarButtonItem(image: UIImage(named: "ic_login_24dp"), style: .plain, target: self, action: #selector(self.openLoginPage))
        
        //home button
        homeButton = UIBarButtonItem(image: UIImage(named: "home"), style: .plain, target: self, action: #selector(self.showMyArticle))
        
        if isLoggedIn() {
            tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!, homeButton!], animated: true)
        } else {
            tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!, loginButton!], animated: true)
        }
        
        tableView?.backgroundColor = UIColor.gray
        
        navigationController?.navigationBar.isTranslucent = true
        
        //connect searchBar
        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.placeholder = "Suche dein Material..."
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        adaptTitle(adsCount: ads.count)
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!], animated: true)
        
        if isLoggedIn() {
            tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!, homeButton!], animated: true)
        } else {
            tabBarController?.navigationItem.setRightBarButtonItems([refreshButton!, loginButton!], animated: true)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
     
        //searchText = searchController.searchBar.text!
        //perform(#selector(test), with: nil, afterDelay: 2)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchString = searchBar.text!
        self.searchController.dismiss(animated: true, completion: nil)
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
    
    func isLoggedIn() -> Bool {
        
        let userToken = Utils.getUserToken()
        if userToken == "" {
            return false
        } else {
            return true
        }
    }
    
    func openLoginPage() {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPage") as! LoginController
        self.navigationController?.present(newViewController, animated: true, completion: nil)
        
        /*let sb = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = sb.instantiateViewController(withIdentifier: "loginPage") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController*/
    }
    
    func refreshArticles() {
        
        //todo searchbar auch an anderen stellen "" setzen!!
        self.searchController.searchBar.text = ""
        ads.removeAll()
        getMyBookmaks(type: "all")
    }
    
    func showMyArticle() {
        
        ads.removeAll()
        getMyBookmaks(type: "my")
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
        
        //TODO das ist mist, alamofire in extra func rufen?? wahrscheinlich...
        var url: URL
        
        if type == "all" {
            //all articles
            url = URL(string: "http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=0&size=30")!
            
        } else if type == "search" {
            //search for article
            url = URL(string: "http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=0&size=30&description=\(searchString!)")!
            print("http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=0&size=30&description=\(searchString!)")
            
        } else {
            //my articles
            let userToken = Utils.getUserToken()
            let urlString = Urls.getMyArticles + "?token=\(userToken)&page=0&size=30"
            url = URL(string: urlString)!
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            
            //print(json)
            //todo auslagern hier
            let total =  json["total"] as! Int
            if total == 0 && type == "search" {
                
                let alert = UIAlertController(title: "Suche erfolglos!", message: "Dies Suche hat leider kein Ergebnis gebracht :-(", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.tableView.backgroundColor = UIColor.white
            }

            
            for dictionary in json["ads"] as! [[String: Any]] {
                
                let title = dictionary["title"] as? String
                let descriptions = dictionary["description"] as? String
                let price = dictionary["price"] as? Int
                let userId = dictionary["userId"] as? String
                let location = dictionary["locationName"] as? String
                let date = dictionary["date"] as? Double
                let articleId = dictionary["id"] as? Int32
                var urls = dictionary["urls"] as? String
                let coordinates = dictionary["location"] as! [String: Any]
                let latLng = coordinates["coordinates"] as! [Double]
                let lat = latLng[0]
                let lng = latLng[1]
                
                if urls == nil {
                    urls = ""
                }
                
                let ad = Ad(title: title!, desc: descriptions!, urls: urls!, price: price!, location: location!, date: date!, userId: userId!, articleId: articleId!, lat: lat, lng: lng)
                
                self.ads.append(ad)
            }

            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.adaptTitle(adsCount: self.ads.count)
            })
            
            }.resume()
    }
    
    func adaptTitle(adsCount: Int) {
        self.tabBarController?.title = "Anzeigen: " + String(self.ads.count)
    }
    
    func getPictureUrl(str: String) -> String {
        let ind = str.characters.split{$0 == ","}.map(String.init)
        if ind.count > 0 {
            return ind[0]
        } else {
            return "1"
        }
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
                }
            }
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()

extension ViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: AdCell? = tableView.dequeueReusableCell(withIdentifier: "AdCell") as? AdCell
        
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
        
        //location
        cell?.location?.text = currentAd.location
        cell?.lat = currentAd.lat
        cell?.lng = currentAd.lng
        
        //date
        cell?.date?.text = getFormatedDate(date: currentAd.date)
        
        //price
        cell?.price?.text = String(currentAd.price) + " €"
        
        //pictureURLs
        cell?.pictureURL = currentAd.urls
        
        //bookmark
        if myBookmarks.contains(currentAd.articleId) {
            cell?.bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_white_36pt"), for: .normal)
        } else {
            cell?.bookmarkButton.setImage(#imageLiteral(resourceName: "ic_star_outline_white_36pt"), for: .normal)
        }
        
        cell?.myBookmarks = self.myBookmarks
        
        //image
        let imageId = getPictureUrl(str: ads[indexPath.item].urls)
        
        let urlString = "http://178.254.54.25:9876/api/V3/pictures/\(imageId)"
        
        let url = URL(string: urlString)
        
        cell?.bild.image = UIImage(named: "lks_logo_1024x1024")
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            cell?.bild.image = imageFromCache
            
        } else {
        
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    let imageToCache = UIImage(data:data!)
                    if imageToCache != nil {
                        imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                        cell?.bild.image = imageToCache
                    }
                })
            }.resume()
        }
        
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
    
    func getFormatedDate(date: Double) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("ddMMMyyyy")
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let date = Date(timeIntervalSince1970: (date / 1000.0))
        return dateFormatter.string(from: date)
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
