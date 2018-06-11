//
//  CreateRouteViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 10/06/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class CreateRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FatecHeaderDelegate {
    let appData: AppData = AppData.sharedInstance
    var filteredPois: [Location]? = nil
    var update = false
    
    var from: Location? {
        didSet {
            setup()
        }
    }
    var to: Location? {
        didSet {
            setup()
        }
    }
    
    weak var embedParent: EmbeddedViewController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var fixedLocationLabel: UILabel!
    
    @IBOutlet weak var fixedLabel: UILabel!
    @IBOutlet weak var dynamicLabel: UILabel!
    
    @IBOutlet weak var fromStack: UIStackView!
    @IBOutlet weak var toStack: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: FatecHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.header.title = "Itinerário"        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update = true
        setup()
    }
    
    func setup() {
        if update {
            if from == nil && to != nil {
                fixedLabel.text = "Até:"
                dynamicLabel.text = "De:"
                self.fixedLocationLabel.text = to?.title
            } else if from != nil && to == nil {
                fixedLabel.text = "De:"
                dynamicLabel.text = "Até:"
                self.fixedLocationLabel.text = from?.title
            } else if let from = from, let to = to {
                if let route = appData.pointsOfInterest.routes.route(from: from, to: to) {
                    embedParent?.hideCreateRoute()
                    embedParent?.delegate?.selectedPoi = route
                } else {
                    // TODO show alert there is no route
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func remove() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var locations: [Location] {
        return appData.pointsOfInterest.locationsForList.filter({ l in l != self.from && l != self.to })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filtered = filteredPois {
            return filtered.count
        } else {
            return self.locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "createRouteCell")
        let listable: PointOfInterest
        if let filtered = filteredPois {
            listable = filtered[indexPath.row]
        } else {
            listable = self.locations[indexPath.row]
        }
        
        cell.textLabel?.text = listable.title
        cell.detailTextLabel?.text = listable.description
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location: Location
        if let filtered = filteredPois {
            location = filtered[indexPath.row]
        } else {
            location = self.locations[indexPath.row]
        }
        if self.from == nil {
            self.from = location
        } else if self.to == nil {
            self.to = location
        }
    }
    
    func filterPois(_ text: String) {
        if text.isEmpty {
            filteredPois = []
        } else {
            filteredPois = self.locations.filter { poi in
                return poi.description.lowercased().contains(text.lowercased()) || poi.title.lowercased().contains(text.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPois(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func closed() {
        embedParent?.hideCreateRoute()
    }
}
