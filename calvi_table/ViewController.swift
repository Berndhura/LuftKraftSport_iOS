//
//  ViewController.swift
//  calvi_table
//
//  Created by bernd wichura on 16.08.17.
//  Copyright © 2017 bernd wichura. All rights reserved.
//  luftkraftsport

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ads: [Ad] = []
    
    var searchController: UISearchController!
    var resultController = UITableViewController()
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Test")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAds()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset = UIEdgeInsets(top: -64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 10/250, green: 100/250, blue: 200/250, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.title = "Luftkraftsport"
        
        let leftButton =  UIBarButtonItem(title: "New", style: UIBarButtonItemStyle.plain, target: self, action: #selector(save))
        tabBarController?.navigationItem.rightBarButtonItem = leftButton
        tabBarController?.navigationItem.title = "Luftkraftsport"
        
        
        tableView?.backgroundColor = UIColor.gray
        
        navigationController?.navigationBar.isTranslucent = true

        self.searchController = UISearchController(searchResultsController: self.resultController)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
}
    func save() {
        //TODO login falls nicht eingelogged
        //self.performSegue(withIdentifier: "createNewAd", sender: self)
        
        print("save")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func fetchAds() {
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/articles?lat=0.0&lng=0.0&distance=10000000&page=0&size=30")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            print(json)
            
            for dictionary in json["ads"] as! [[String: Any]] {
                
                let title = dictionary["title"] as? String
                let descriptions = dictionary["description"] as? String
                let price = dictionary["price"] as? Int
                let userId = dictionary["userId"] as? String
                let location = dictionary["locationName"] as? String
                let date = dictionary["date"] as? Int32
                let articleId = dictionary["id"] as? Int32
                var urls = dictionary["urls"] as? String
                
                if urls == nil {
                    urls = ""
                }
                
                let ad = Ad(title: title!, desc: descriptions!, urls: urls!, price: price!, location: location!, date: date!, userId: userId!, articleId: articleId!)
                
                //print(ad.urls)
                
                self.ads.append(ad)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
            }.resume()
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
            
            if cell != nil {
                let indexPath: IndexPath? = self.tableView.indexPath(for: cell!)
                if indexPath != nil {
                    let ad: Ad = ads[indexPath!.row]
                    detailViewController.anzeig = ad.title
                    detailViewController.pictureUrl = getPictureUrl(str: ad.urls)
                    detailViewController.desc = ad.desc
                    detailViewController.price = ad.price
                    detailViewController.location = ad.location
                    detailViewController.date = ad.date
                }
            }
        }
    }
}

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
        
        //title
        cell?.title?.text = currentAd.title
        
        //description
        cell?.desc?.text = currentAd.desc
        
        //articleId
        //cell?.articleId = currentAd.articleId
        
        //price
        cell?.price?.text = String(currentAd.price)
        
        //image
        let imageId = getPictureUrl(str: ads[indexPath.item].urls)
        
        let url = URL(string: "http://178.254.54.25:9876/api/V3/pictures/\(imageId)/thumbnail")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                cell?.bild.image = image
            })
        }.resume()
        
        cell?.bild?.sd_setImage(with: url)

        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0//UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, heightFor section: Int) -> CGFloat{
        return 150.0
    }
}
