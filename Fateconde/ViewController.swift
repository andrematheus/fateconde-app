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
    
    var selectedPoi: PointOfInterest? = nil {
        didSet {
            if let title = selectedPoi?.title {
                locationLabel?.text = title
            }
            updateViewButtons()
            mapController?.lookAt(poi: selectedPoi)
            bottomSheetController?.selectedPoiChanged(selectedPoi)
            
            if let poi = selectedPoi {                
                if poi.hasMoreThanOneLevel {
                    updateLevels(poi: poi)
                    mapController?.showLevel(selectedLevel)
                } else {
                    if let location = poi as? Location {
                        if let building = location.building {
                            updateLevels(poi: building)
                        }
                        selectedLevel = location.id.buildingLevel
                    } else {
                        selectedLevel = 0
                        self.levels.isHidden = true
                    }
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
            mapController?.showLevel(selectedLevel)
            if self.levels.numberOfSegments > 0 {
                let levels: [Int]
                if let location = selectedPoi as? Location {
                    levels = location.building?.levels ?? []
                } else if let building = selectedPoi as? Building {
                    levels = building.levels
                } else {
                    levels = []
                }
                if let index = levels.index(of: selectedLevel) {
                    if self.levels.selectedSegmentIndex != index {
                        self.levels.selectedSegmentIndex = index
                    }
                }
                if let poi = selectedPoi {
                    if let location = poi as? Location {
                        if location.id.buildingLevel != selectedLevel {
                            let level = selectedLevel
                            self.selectedPoi = location.building
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
        if let poi = selectedPoi {
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
        if self.bottomSheetHeight.constant == bottomSheetMedium {
            self.animateBottomSheetHeight(newHeight: bottomSheetLarge)
        } else if self.bottomSheetHeight.constant == bottomSheetSmall {
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        }
    }
    
    func shrinkBottomSheet() {
        if self.bottomSheetHeight.constant == bottomSheetLarge {
            self.animateBottomSheetHeight(newHeight: bottomSheetMedium)
        } else if self.bottomSheetHeight.constant == bottomSheetMedium {
            self.animateBottomSheetHeight(newHeight: bottomSheetSmall)
        }
    }
    
    var bottomSheetIsHuge: Bool {
        return self.bottomSheetHeight.constant > bottomSheetMedium
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

