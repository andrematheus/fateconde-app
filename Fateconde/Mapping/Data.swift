//
//  Data.swift
//  Fateconde
//
//  Created by André Roque Matheus on 09/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation
import PointOfInterest

final class AppData {
    static let sharedInstance = AppData()
    let pointsOfInterest: MapData
    let fatecHelper: FatecMapHelper
    let buildingHelpers: [String: BuildingMapHelper]
    let locationHelpers: [String: LocationMapHelper]
    
    init() {
        guard let path = Bundle.main.path(forResource: "Fatec", ofType: "json") else {
            preconditionFailure("Failed to find Locations file.")
        }
        guard let data = FileManager.default.contents(atPath: path) else {
            preconditionFailure("Failed to load Locations data.")
        }
        guard let pois = try? MapData.fromData(data) else {
            preconditionFailure("Failed to convert Locations data.")
        }
        self.pointsOfInterest = pois
        
        self.fatecHelper = FatecMapHelper(fatec: pointsOfInterest.fatec)
        var buildingHelpers: [String: BuildingMapHelper] = [:]
        for building in pointsOfInterest.buildings {
            buildingHelpers[building.code] = BuildingMapHelper(building: building)
        }
        self.buildingHelpers = buildingHelpers
        
        var locationHelpers: [String: LocationMapHelper] = [:]
        for location in pointsOfInterest.locations {
            locationHelpers[location.id.code] = LocationMapHelper(location: location)
        }
        self.locationHelpers = locationHelpers
    }
}
