//
//  BottomSheetViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

protocol BottomSheetDelegate: class {
    func growBottomSheet()
    func shrinkBottomSheet()
}

class BottomSheetViewController: UITableViewController, UISearchBarDelegate {
    weak var delegate: BottomSheetDelegate? = nil
    let appData: AppData = AppData.sharedInstance

    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO return 1 section per building
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO return number of points of interest in corresponding building
        return appData.pointsOfInterest.listing().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)

        let location = appData.pointsOfInterest.listing()[indexPath.row]
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.id.buildingCode

        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.growBottomSheet()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.shrinkBottomSheet()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
