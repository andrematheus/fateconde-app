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
    var bottomSheetIsHuge: Bool { get }
    var selectedPoi: PointOfInterest? { get set }
}

class BottomSheetViewController: UITableViewController, UISearchBarDelegate {
    weak var delegate: BottomSheetDelegate? = nil
    weak var searchBar: UISearchBar!
    let appData: AppData = AppData.sharedInstance
    var filteredPois = [PointOfInterest]()

    override func numberOfSections(in tableView: UITableView) -> Int {
        if filteredPois.isEmpty {
            return appData.pointsOfInterest.buildingsForList.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPois.isEmpty {
            if section == 0 {
                return appData.pointsOfInterest.buildingsForList.count
            } else {
                let building = appData.pointsOfInterest.buildingsForList[section - 1]
                return building.locationsForList.count
            }
        } else {
            return filteredPois.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointOfInterestCell", for: indexPath)
        let listable: PointOfInterest
        if filteredPois.isEmpty {
            if indexPath.section == 0 {
                listable = appData.pointsOfInterest.buildingsForList[indexPath.row]
            } else {
                let building = appData.pointsOfInterest.buildingsForList[indexPath.section - 1]
                listable = building.locationsForList[indexPath.row]
            }
        } else {
            listable = filteredPois[indexPath.row]
        }
        cell.textLabel?.text = listable.title
        cell.detailTextLabel?.text = listable.description
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredPois.isEmpty {
            if section == 0 {
                return "Prédios"
            } else {
                return appData.pointsOfInterest.buildingsForList[section - 1].name
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate?.bottomSheetIsHuge ?? false {
            delegate?.shrinkBottomSheet()
        }
        if filteredPois.isEmpty {
            if indexPath.section == 0 {
                let building = appData.pointsOfInterest.buildingsForList[indexPath.row]
                delegate?.selectedPoi = building
            } else {
                let building = appData.pointsOfInterest.buildingsForList[indexPath.section - 1]
                let location = building.locationsForList[indexPath.row]
                delegate?.selectedPoi = location
            }
        } else {
            let poi = filteredPois[indexPath.row]
            searchBar.resignFirstResponder()
            delegate?.selectedPoi = poi
        }
    }
    
    func filterPois(_ text: String) {
        if text.isEmpty {
            filteredPois = []
        } else {
            filteredPois = appData.pointsOfInterest.pointsOfInterestForList.filter { poi in
                return poi.description.lowercased().contains(text.lowercased()) || poi.title.lowercased().contains(text.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPois(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.growBottomSheet()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if delegate?.bottomSheetIsHuge ?? false {
            delegate?.shrinkBottomSheet()
        }        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
