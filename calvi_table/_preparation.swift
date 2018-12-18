//
//  _preparation.swift
//  calvi_table
//
//  Created by bernd wichura on 05.12.18.
//  Copyright © 2018 bernd wichura. All rights reserved.
//

import Foundation


/*
 
 let v = UIView(frame: CGRect(x: 0, y: searchController.searchBar.frame.height + safeAreaHight!, width: searchController.searchBar.frame.width, height: 60))
 v.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
 v.alpha = 0.95
 
 let stackView   = UIStackView(frame: CGRect(x: 0, y: 0, width: searchController.searchBar.frame.width, height: 50.0))
 stackView.axis  = .horizontal
 stackView.distribution = .fillEqually
 stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
 stackView.isLayoutMarginsRelativeArrangement = true
 stackView.spacing = 5.0
 //stackView.addArrangedSubview(currentSearchesBtn)
 stackView.addArrangedSubview(savedSearches)
 
 v.addSubview(stackView)

//aktuelle suchen
let currentSearchesBtn = UIButton()
currentSearchesBtn.backgroundColor = appMainColorBlue
currentSearchesBtn.setTitle(NSLocalizedString("show_searches", comment: ""), for: .normal)
currentSearchesBtn.addTarget(self, action: #selector(btnTapped), for: .touchDown)


//last searches
let lastSearchesStack   = UIView(frame: CGRect(x: 0, y: 160, width: searchController.searchBar.frame.width, height: 250.0))
lastSearchesStack.layoutMargins = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 5)

var h: CGFloat = 50.0
for str in getLastSearch() {
    print("neu: ")
    print(str)
    let label = UILabel(frame: CGRect(x: 0, y: h, width: searchController.searchBar.frame.width, height: 30))
    label.text = str
    label.textColor = .black
    label.isUserInteractionEnabled = true
    label.backgroundColor = appMainColorBlue
    let ge = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    label.addGestureRecognizer(ge)
    lastSearchesStack.addSubview(label)
    h = h + 30.0
}

searchController.view.addSubview(lastSearchesStack)

//let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height

func tapped(_ sender: UITapGestureRecognizer) {
    print(sender)
}

//save last search text in user defaults to show next time to user
func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    if let lastSearchText = searchBar.text {
        if lastSearchText != "" {
            lastSearch.append(lastSearchText)
            let defaults = UserDefaults.standard
            defaults.set(lastSearch, forKey: "last_search")
        }
    }
}

func getLastSearch() -> [String] {
    if let str = UserDefaults.standard.stringArray(forKey: "last_search") {
        return str
    } else {
        return ["maul"]
    }
}


nice for buttons:

let currentSearchesButton: UIButton = {
    let btn = UIButton(type: .system)
    //btn.setImage("home", for: .normal)
    return btn
}()
 
 
 merken des letzten viewControllers...
 
 let ind = self.tabBarController?.selectedIndex
 print("komme von: ")
 print(ind!)
 let defaults:UserDefaults = UserDefaults.standard
 defaults.set(ind, forKey: "index")
 defaults.synchronize()
 
 setzen im letzten VC :
 
 self.tabBarController?.selectedIndex = 1
 
 klappt aber nicht
 
 

*/

