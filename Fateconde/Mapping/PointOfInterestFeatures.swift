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

protocol MappingLayer {
    func install(style: MGLStyle)
    func show()
    func hide()
}

class FatecColors: UIColor {
    // TODO: cores da fatec
    static let cinza = UIColor.gray
    static let branco = UIColor.white
    static let vermelho = UIColor.red
}

struct ZoomableInfo<T> {
    private let byLevel: [MapZoomLevel: T]
    let defaultValue: T
    
    init(_ values: [MapZoomLevel: T], defaultValue: T) {
        byLevel = values
        self.defaultValue = defaultValue
    }
    
    init(defaultValue: T) {
        byLevel = [:]
        self.defaultValue = defaultValue
    }
    
    func forLevel(_ level: MapZoomLevel) -> T {
        if let t = byLevel[level] {
            return t
        } else {
            return defaultValue
        }
    }
    
    func map<R>(_ transform: (T) -> R, defaultValue: R) -> ZoomableInfo<R> {
        let transformed: [MapZoomLevel: R] = self.byLevel.mapValues(transform)
        return ZoomableInfo<R>(transformed, defaultValue: defaultValue)
    }
    
    var nsExpression: NSExpression {
        if byLevel.isEmpty {
            return NSExpression(forConstantValue: self.defaultValue)
        } else {
            var byLevel = self.byLevel
            for zoom in MapZoomLevel.allValues {
                if !byLevel.keys.contains(zoom) {
                    byLevel[zoom] = defaultValue
                }
            }
            let byZoomDouble = Dictionary.init(uniqueKeysWithValues: byLevel.map {(key, value) in
                return (key.rawValue, value)
            })
            return NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                byZoomDouble)
        }
    }
}

struct ImageLayer: MappingLayer {
    let identifier: String
    let image: UIImage
    let source: MGLImageSource
    let layer: MGLRasterStyleLayer
    let attributes: ImageLayerAttributes
    
    init(identifier: String, polygon: QuadPolygon, image: UIImage, attributes: ImageLayerAttributes) {
        self.image = image
        let quad = polygon.mglCoordinateQuad
        self.identifier = identifier
        self.attributes = attributes
        source = MGLImageSource(identifier: "fatec-\(identifier)-image-source", coordinateQuad: quad, image: image)
        layer = MGLRasterStyleLayer(identifier: "fatec-\(identifier)-image-layer", source: source)
        attributes.applyTo(layer)
    }
    
    func install(style: MGLStyle) {
        style.addSource(source)
        if let annotationsLayer = style.layer(withIdentifier: "com.mapbox.annotations.points") {
            style.insertLayer(layer, below: annotationsLayer)
        } else {
            style.addLayer(layer)
        }
    }
    
    func show() {
        layer.isVisible = true
    }
    
    func hide() {
        layer.isVisible = false
    }
}

struct OutlineLayer: MappingLayer {
    let identifier: String
    let source: MGLShapeSource
    let strokeLayer: MGLLineStyleLayer
    let fillLayer: MGLFillStyleLayer
    let strokeAttributes: LineLayerAttributes
    let fillAttributes: FillLayerAttributes
    let feature: MGLPolygonFeature
    
    init(identifier: String, coordinates: [CLLocationCoordinate2D],
         strokeAttributes: LineLayerAttributes, fillAttributes: FillLayerAttributes) {
        self.identifier = identifier
        self.feature = MGLPolygonFeature(coordinates: coordinates, count: UInt(coordinates.count))
        let features = [feature]
        self.source = MGLShapeSource(identifier: "\(identifier)-outline-source", features: features, options: nil)
        self.strokeLayer = MGLLineStyleLayer(identifier: "\(identifier)-outline-stroke", source: source)
        self.fillLayer = MGLFillStyleLayer(identifier: "\(identifier)-outline-fill", source: source)
        self.strokeAttributes = strokeAttributes
        self.fillAttributes = fillAttributes
        self.strokeAttributes.applyTo(strokeLayer)
        self.fillAttributes.applyTo(fillLayer)
    }
    func install(style: MGLStyle) {
        style.addSource(source)
        style.addLayer(fillLayer)
        style.addLayer(strokeLayer)
    }
    
    func show() {
        strokeLayer.isVisible = true
        fillLayer.isVisible = true
    }
    
    func hide() {
        strokeLayer.isVisible = false
        fillLayer.isVisible = false
    }

}

struct NameLayer: MappingLayer {
    let identifier: String
    let text: String
    let source: MGLShapeSource
    let pointFeature: MGLPointFeature
    let symbolLayer: MGLSymbolStyleLayer
    let attributes: SymbolTextLayerAttributes
    
    init(identifier: String, coordinate: CLLocationCoordinate2D, text: String, attributes: SymbolTextLayerAttributes) {
        self.identifier = identifier
        self.text = text
        pointFeature = MGLPointFeature()
        pointFeature.identifier = "fatec-feature-\(identifier)"
        pointFeature.coordinate = coordinate
        pointFeature.attributes = [
            "name": text
        ]
        let features = [pointFeature]
        source = MGLShapeSource(identifier: "fatec-\(identifier)-name", features: features, options: nil)
        symbolLayer = MGLSymbolStyleLayer(identifier: "fatec-\(identifier)-name-layer", source: source)
        symbolLayer.text = NSExpression(forConstantValue: text)
        self.attributes = attributes
        attributes.applyTo(symbolLayer)
    }

    func install(style: MGLStyle) {
        style.addSource(source)
        style.addLayer(symbolLayer)
    }
    
    func show() {
        symbolLayer.isVisible = true
    }
    
    func hide() {
        symbolLayer.isVisible = false
    }
}

struct LineLayerAttributes {
    let lineColor: UIColor
    let lineWidth: ZoomableInfo<Double>
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLLineStyleLayer) {
        layer.lineColor = NSExpression(forConstantValue: lineColor)
        layer.lineWidth = lineWidth.nsExpression
        layer.lineOpacity = visibility.map(boolToVisibility, defaultValue: 0.0).nsExpression
    }
}

struct FillLayerAttributes {
    let fillColor: UIColor
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLFillStyleLayer) {
        layer.fillColor = NSExpression(forConstantValue: fillColor)
        layer.fillOpacity = visibility.map(boolToVisibility, defaultValue: 0.0).nsExpression
    }
}

func boolToVisibility(_ bool: Bool) -> Double {
    if bool {
        return 1.0
    } else {
        return 0.0
    }
}

struct SymbolTextLayerAttributes {
    let textSize: ZoomableInfo<Double>
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLSymbolStyleLayer) {
        print(layer.identifier)
        layer.textAllowsOverlap = NSExpression(forConstantValue: true)
        layer.textFontSize = textSize.nsExpression
        layer.textOpacity = visibility.map(boolToVisibility, defaultValue: 0.0).nsExpression
    }
}

struct ImageLayerAttributes {
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLRasterStyleLayer) {
        layer.rasterOpacity = visibility.map(boolToVisibility, defaultValue: 0.0).nsExpression
    }
}

class FatecMapHelper {
    let identifier = "fatec"
    let fatec: Fatec
    let outlineLayer: MappingLayer
    let imageLayer: MappingLayer
    let nameLayer: MappingLayer
    let stroke = LineLayerAttributes(lineColor: FatecColors.cinza,
                                     lineWidth: ZoomableInfo<Double>([:], defaultValue: 1.0),
                                     visibility: ZoomableInfo<Bool>(defaultValue: true))
    let fill = FillLayerAttributes(fillColor: FatecColors.branco,
                                   visibility: ZoomableInfo<Bool>(defaultValue: true))
    
    init(fatec: Fatec) {
        self.fatec = fatec
        self.outlineLayer = OutlineLayer(identifier: identifier, coordinates: fatec.quadPolygon.coordinates, strokeAttributes: stroke, fillAttributes: fill)
        
        if let fatecPlanImage = fatec.planImage {
            self.imageLayer = ImageLayer(identifier: identifier, polygon: fatec.quadPolygon, image: fatecPlanImage,
                                           attributes: ImageLayerAttributes(visibility: ZoomableInfo<Bool>([MapZoomLevel.Fatec: true], defaultValue: false)))
        } else {
            self.imageLayer = self.outlineLayer
        }
        
        self.nameLayer = NameLayer(identifier: identifier, coordinate: fatec.point, text: "FATEC",
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 12.0), visibility: ZoomableInfo<Bool>([MapZoomLevel.Surroundings: true], defaultValue: false)))
    }
}

class BuildingMapHelper {
    let identifier: String
    let building: Building
    let outlineLayer: MappingLayer
    let planLayers: [Int: MappingLayer]
    let nameLayer: MappingLayer
    let stroke = LineLayerAttributes(lineColor: FatecColors.cinza,
                                     lineWidth: ZoomableInfo<Double>([:], defaultValue: 1.0),
                                     visibility: ZoomableInfo<Bool>([.Fatec: true], defaultValue: false))
    let fill = FillLayerAttributes(fillColor: FatecColors.branco,
                                   visibility: ZoomableInfo<Bool>([.Fatec: true], defaultValue: false))
    
    init(building: Building) {
        self.building = building
        self.identifier = "building-\(building.code)"
        self.outlineLayer = OutlineLayer(identifier: identifier, coordinates: building.quadPolygon.coordinates,
                                         strokeAttributes: stroke, fillAttributes: fill)
        // TODO: use short name
        self.nameLayer = NameLayer(identifier: identifier, coordinate: building.point, text: building.name,
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 9.0), visibility: ZoomableInfo<Bool>([MapZoomLevel.Fatec: true], defaultValue: false)))
        // TODO: play layers by floor
        if let image = building.planImage {
            self.planLayers = [
                0: ImageLayer(identifier: "\(identifier)-floor-0", polygon: building.quadPolygon,
                              image: image,
                              attributes: ImageLayerAttributes(visibility: ZoomableInfo<Bool>([MapZoomLevel.Building: true], defaultValue: false)))
            ]
        } else {
            self.planLayers = [:]
        }
    }
}

class LocationMapHelper {
    let identifier: String
    let location: Location
    let nameLayer: MappingLayer
    
    init(location: Location) {
        self.identifier = "location-\(location.id.code)"
        self.location = location
        self.nameLayer = NameLayer(identifier: identifier, coordinate: location.point, text: location.name,
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 9.0), visibility: ZoomableInfo<Bool>([MapZoomLevel.Building: true], defaultValue: false)))
    }
}

extension QuadPolygon {
    var mglCoordinateQuad: MGLCoordinateQuad {
        return MGLCoordinateQuad(topLeft: self.coordinates[0],
                                 bottomLeft: self.coordinates[1],
                                 bottomRight: self.coordinates[2],
                                 topRight: self.coordinates[3])
    }
}
