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
        guard let path = Bundle.main.path(forResource: "Locations", ofType: "plist") else {
            preconditionFailure("Failed to find Locations file.")
        }
        guard let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, Any> else {
            preconditionFailure("Failed to load Locations file.")
        }
        guard let pois = try? dict.toPointsOfInterest() else {
            preconditionFailure("Failed to parse Locations file.")
        }
        self.pointsOfInterest = pois
    }
}
