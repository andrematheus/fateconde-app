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
    var selectedPoi: PointOfInterest { get set }
    var bottomSheetController: BottomSheetViewController? { get set }
}

class BottomSheetViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet var embeddingParent: EmbeddedViewController!
    
    weak var delegate: BottomSheetDelegate? = nil {
        didSet {
            self.delegate?.bottomSheetController = self
        }
    }
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
    
    func selectedPoiChanged(_ poi: PointOfInterest?) {
        if let poi = poi {
            if let vc = self.embeddingParent {
                if poi.displaysInfo {
                    if let poi = poi as? Location {
                        let poiInfo = PoiInfoViewController(nibName: "PoiInfoViewController", bundle: nil)
                        poiInfo.poi = poi
                        vc.displayPoiInfo(poiInfo: poiInfo)
                    } else if let poi = poi as? Route<Location> {
                        let routeInfo = RouteInfoViewController(nibName: "RouteInfoViewController", bundle: nil)
                        routeInfo.route = poi
                        vc.displayRouteInfo(routeInfo: routeInfo)
                    }
                } else {
                    vc.hidePoiInfo()
                    vc.hideRouteInfo()
                }
            }
            if filteredPois.isEmpty {
                if let location = poi as? Location {
                    if let building = location.building,
                        let section = self.appData.pointsOfInterest.buildingsForList.index(of: building),
                        let row = building.locationsForList.index(of: location) {
                        let indexPath = IndexPath(row: row, section: section + 1)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        return
                    }
                } else if let building = poi as? Building {
                    let section = 0
                    if let row = self.appData.pointsOfInterest.buildingsForList.index(of: building) {
                        let indexPath = IndexPath(row: row, section: section)
                        self.tableView.selectRow(at:indexPath, animated: true, scrollPosition: .top)
                        return
                    }
                }
            } else {
                if let location = poi as? Location {
                    if let row = filteredPois.index(where: { p in
                        if let l = p as? Location {
                            return l == location
                        } else {
                            return false
                        }
                    }) {
                        let indexPath = IndexPath(row: row, section: 0)
                        self.tableView.selectRow(at:indexPath, animated: true, scrollPosition: .top)
                        return
                    }
                } else if let building = poi as? Building {
                    if let row = filteredPois.index(where: { p in
                        if let l = p as? Building {
                            return l == building
                        } else {
                            return false
                        }
                    }) {
                        let indexPath = IndexPath(row: row, section: 0)
                        self.tableView.selectRow(at:indexPath, animated: true, scrollPosition: .top)
                        return
                    }
                }
            }
            if let row = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: row, animated: true)
            }
        } else {
            if let row = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: row, animated: true)
            }
            if let vc = self.embeddingParent {
                vc.hidePoiInfo()
            }
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
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if delegate?.bottomSheetIsHuge ?? false {
            delegate?.shrinkBottomSheet()
        }
        if let poi = delegate?.selectedPoi {
            self.selectedPoiChanged(poi)
        }
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
