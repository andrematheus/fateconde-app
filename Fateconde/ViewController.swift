//
//  ViewController.swift
//  Fateconde
//
//  Created by André Roque Matheus on 08/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import UIKit
import PointOfInterest

class ViewController: UIViewController, BottomSheetDelegate {
    var data: AppData = AppData.sharedInstance
    var mapController: MapboxViewController?
    let bottomSheetSmall: CGFloat = 66
    let bottomSheetMedium: CGFloat = 240
    var bottomSheetLarge: CGFloat {
        return self.view.frame.height - 80
    }
    var bottomSheetController: BottomSheetViewController? = nil

    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSheet: UIView!
    @IBOutlet weak var showFatecButton: UIButton!
    @IBOutlet weak var showSurroundingsButton: UIButton!
    @IBOutlet weak var locationLabel: PillLabel!
    @IBOutlet weak var levels : UISegmentedControl!
    var theLevels: [Int] = []
    var routeLeg = 0
    
    var selectedPoi: PointOfInterest = AppData.sharedInstance.pointsOfInterest.fatec {
        didSet {
            locationLabel.text = selectedPoi.title
            updateViewButtons()
            mapController?.lookAt(poi: selectedPoi)
            bottomSheetController?.selectedPoiChanged(selectedPoi)
            
            if selectedPoi.hasMoreThanOneLevel {
                updateLevels(poi: selectedPoi)
                mapController?.showLevel(selectedLevel)
            } else {
                if let location = selectedPoi as? Location {
                    if let building = location.building {
                        updateLevels(poi: building)
                    }
                    selectedLevel = location.id.buildingLevel
                } else if let leg = selectedPoi as? LocationRouteLeg {
                    selectedLevel = leg.from.id.buildingLevel
                } else if let route = selectedPoi as? Route<Location> {
                    selectedLevel = route.from.id.buildingLevel
                } else {
                    selectedLevel = 0
                    self.levels.isHidden = true
                }
            }
        }
    }
    
    func updateLevels(poi: PointOfInterest) {
        self.levels.removeAllSegments()
        for level in poi.levels {
            self.levels.insertSegment(withTitle: floorLabel(level),
                                      at: self.levels.numberOfSegments,
                                      animated: false)
        }
        self.theLevels = poi.levels
        if let index = self.theLevels.index(of: selectedLevel) {
            self.levels.selectedSegmentIndex = index
        }
        self.levels.isHidden = false
    }
    
    var selectedLevel: Int = 0 {
        didSet {
            print("will show \(selectedLevel)")
            mapController?.showLevel(selectedLevel)
            if self.levels.numberOfSegments > 0 {
                let levels: [Int]
                if let location = selectedPoi as? Location {
                    levels = location.building?.levels ?? []
                } else if let building = selectedPoi as? Building {
                    levels = building.levels
                } else if let leg = selectedPoi as? LocationRouteLeg {
                    levels = leg.from.building?.levels ?? []
                } else {
                    levels = []
                }
                if let index = levels.index(of: selectedLevel) {
                    if self.levels.selectedSegmentIndex != index {
                        self.levels.selectedSegmentIndex = index
                    }
                }
                let poi = selectedPoi
                if let location = poi as? Location {
                    if location.id.buildingLevel != selectedLevel {
                        let level = selectedLevel
                        self.selectedPoi = location.building ?? data.pointsOfInterest.fatec
                        selectedLevel = level
                    }
                }
                if let building = poi as? Building {
                    if selectedLevel >= building.levels.count {
                        selectedLevel = building.levels.last ?? building.levels.first ?? 0
                    }
                }
            }
        }
    }
    
    @IBAction func levelChanged(_ sender: Any) {
        let index = self.levels.selectedSegmentIndex
        let newLevel = theLevels[index]
        self.selectedLevel = newLevel
    }
   
    override func viewDidLoad() {
        mapController?.setup(with: self)
        selectedPoi = data.pointsOfInterest.fatec
        self.levels.isHidden = true
    }
    
    @IBAction func showFatec(_ sender: Any) {
        self.selectedPoi = data.pointsOfInterest.fatec
    }
    
    
    @IBAction func showSurroundings(_ sender: Any) {
        self.selectedPoi = data.pointsOfInterest.surroundings
    }
    
    func updateViewButtons() {
        let poi = selectedPoi
        if poi is Fatec {
            self.showFatecButton.isSelected = true
            self.showSurroundingsButton.isSelected = false
        } else if poi is Surroundings {
            self.showFatecButton.isSelected = false
            self.showSurroundingsButton.isSelected = true
        } else {
            self.showFatecButton.isSelected = false
            self.showSurroundingsButton.isSelected = false
        }
    }
    
    @IBAction func toggleDebug(_ sender: Any) {
        mapController?.toggleDebug()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let locationController = destination as? EmbeddedViewController {
            locationController.delegate = self
            locationController.forwardDelegate(delegate: self)
        } else if let mapController = destination as? MapboxViewController {
            self.mapController = mapController
        } else if let debugController = destination as? DebugTableViewController {
            debugController.mainViewController = self
        }
    }
    
    func growBottomSheet() {
        if self.bottomSheetHeight.constant == bottomSheetMedium && canSetHeight(newHeight: bottomSheetLarge) {
            self.animateBottomSheetHeight(newHeight: bottomSheetLarge)
        } else if self.bottomSheetHeight.constant == bottomSheetSmall && canSetHeight(newHeight: bottomSheetMedium){
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        } else if self.bottomSheetHeight.constant == bottomSheetSmall && canSetHeight(newHeight: bottomSheetLarge){
            self.animateBottomSheetHeight(newHeight: bottomSheetLarge)
        }
    }
    
    func shrinkBottomSheet() {
        if self.bottomSheetHeight.constant == bottomSheetLarge && canSetHeight(newHeight: bottomSheetMedium) {
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        } else if self.bottomSheetHeight.constant == bottomSheetMedium && canSetHeight(newHeight: bottomSheetSmall) {
            self.animateBottomSheetHeight(newHeight: bottomSheetSmall)
        } else if self.bottomSheetHeight.constant == bottomSheetLarge && canSetHeight(newHeight: bottomSheetSmall) {
            self.animateBottomSheetHeight(newHeight: bottomSheetSmall)
        }
    }
    
    var bottomSheetIsHuge: Bool {
        return self.bottomSheetHeight.constant > bottomSheetMedium
    }
    
    func updateHeight(allowed: [AllowedHeights]) {
        self.allowedHeights = allowed
    }
    
    var allowedHeights: [AllowedHeights] = AllowedHeights.all {
        didSet {
            if self.allowedHeights.count == 1 {
                self.animateBottomSheetHeight(newHeight: heightForAllowedHeight(allowed: self.allowedHeights[0]))
            } else if self.allowedHeights.count == 2 {
                var found = false
                for ah in self.allowedHeights {
                    if heightForAllowedHeight(allowed: ah) == self.bottomSheetHeight.constant {
                        found = true
                    }
                }
                if !found {
                    self.animateBottomSheetHeight(newHeight: heightForAllowedHeight(allowed: self.allowedHeights[0]))
                }
            }
        }
    }
    
    func canSetHeight(newHeight: CGFloat) -> Bool {
        var found = false
        for ah in self.allowedHeights {
            if heightForAllowedHeight(allowed: ah) == newHeight {
                found = true
            }
        }
        return found
    }
    
    func heightForAllowedHeight(allowed: AllowedHeights) -> CGFloat {
        switch allowed {
        case .maximum: return bottomSheetLarge
        case .medium: return bottomSheetMedium
        case .minimal: return bottomSheetSmall
        }
    }
    
    private func animateBottomSheetHeight(newHeight: CGFloat) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.bottomSheetHeight.constant = newHeight
            self.view.layoutIfNeeded()
        })
        if newHeight < bottomSheetLarge {
            self.bottomSheetController?.searchBar.resignFirstResponder()
        }
    }
}

