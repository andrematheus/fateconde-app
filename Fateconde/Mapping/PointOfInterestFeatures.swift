//
//  PointOfInterestFeatures.swift
//  Fateconde
//
//  Created by André Roque Matheus on 28/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation
import Mapbox
import PointOfInterest

protocol FeatureConverter {
    associatedtype FeatureType: MGLFeature
    
    var features: [FeatureType] { get }
}

struct LineLayerAttributes {
    let lineColor: UIColor
    let lineWidth: Double
}

struct FillLayerAttributes {
    let fillColor: UIColor
}

struct SymbolTextLayerAttributes {
    
}

func unwrapCoordinates(coordinates: Coordinates) -> CLLocationCoordinate2D? {
    switch coordinates {
    case .Point(let coord):
        return coord
    default:
        return nil
    }
}

func unwrapCoordinates(coordinates: Coordinates) -> [CLLocationCoordinate2D]? {
    switch coordinates {
    case .Polygon(let coords):
        return coords[0]
    default:
        return nil
    }
}

public struct BuildingPolygons: FeatureConverter {
    let building: Building
    let lineLayerAttributes = LineLayerAttributes(
        lineColor: UIColor.gray,
        lineWidth: 1.0
        )
    let fillLayerAttributes = FillLayerAttributes(
        fillColor: UIColor.white
    )
    
    var features: [MGLPolygonFeature] {
        let coords = building.outline.geometry.coordinates
        switch coords {
        case .Polygon(let coords):
            return buildPolygonFeatures(coords[0])
        default:
            return []
        }
    }
    
    func buildPolygonFeatures(_ coords: [CLLocationCoordinate2D]) -> [MGLPolygonFeature] {
        return [MGLPolygonFeature(coordinates: coords, count: UInt(coords.count))]
    }
    
    typealias FeatureType = MGLPolygonFeature
}

public struct BuildingPoints: FeatureConverter {
    var features: [MGLPointFeature] {
        let pointFeature = MGLPointFeature()
        pointFeature.identifier = "point-feature-building-\(building.code)"
        let coord: CLLocationCoordinate2D = unwrapCoordinates(coordinates: building.point.geometry.coordinates)!
        pointFeature.coordinate = coord
        pointFeature.attributes = [
            "name": building.name
        ]
        return [pointFeature]
    }
    
    typealias FeatureType = MGLPointFeature
    
    let building: Building
    let symbolTextLayerAttributes = SymbolTextLayerAttributes()
}
