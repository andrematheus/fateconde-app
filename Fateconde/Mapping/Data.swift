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
    let pointsOfInterest: PointsOfInterest
    let buildingOutlines: [BuildingPolygons]
    let buildingPoints: [BuildingPoints]
    
    init() {
        guard let path = Bundle.main.path(forResource: "Fatec", ofType: "json") else {
            preconditionFailure("Failed to find Locations file.")
        }
        guard let data = FileManager.default.contents(atPath: path) else {
            preconditionFailure("Failed to load Locations data.")
        }
        guard let pois = try? data.toPointsOfInterest() else {
            preconditionFailure("Failed to convert Locations data.")
        }
        self.pointsOfInterest = pois
        
        var bps: [BuildingPolygons] = []
        var bpts: [BuildingPoints] = []
        for building in self.pointsOfInterest.allBuildings() {
            bps.append(BuildingPolygons(building: building))
            bpts.append(BuildingPoints(building: building))
        }
        buildingOutlines = bps
        buildingPoints = bpts
    }
}
