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
    var selectedPoi: PointOfInterest? { get set }
}

class BottomSheetViewController: UITableViewController, UISearchBarDelegate {
    weak var delegate: BottomSheetDelegate? = nil
    let appData: AppData = AppData.sharedInstance

    override func numberOfSections(in tableView: UITableView) -> Int {
        return appData.pointsOfInterest.buildingsForList.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return appData.pointsOfInterest.buildingsForList.count
        } else {
            let building = appData.pointsOfInterest.buildingsForList[section - 1]
            return building.locationsForList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)
        let listable: PointOfInterest
        if indexPath.section == 0 {
            listable = appData.pointsOfInterest.buildingsForList[indexPath.row]
        } else {
            let building = appData.pointsOfInterest.buildingsForList[indexPath.section - 1]
            listable = building.locationsForList[indexPath.row]
        }
        cell.textLabel?.text = listable.title
        cell.detailTextLabel?.text = listable.description
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Prédios"
        } else {
            return appData.pointsOfInterest.buildingsForList[section - 1].name
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let building = appData.pointsOfInterest.buildingsForList[indexPath.row]
            delegate?.selectedPoi = building
        } else {
            let building = appData.pointsOfInterest.buildingsForList[indexPath.section - 1]
            let location = building.locationsForList[indexPath.row]
            delegate?.selectedPoi = location
        }
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
