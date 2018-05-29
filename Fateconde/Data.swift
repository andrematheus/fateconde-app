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
    }
}
